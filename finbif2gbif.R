dir.create("logs", showWarnings = FALSE)

log_file_name <- sprintf("logs/update-%s.txt", Sys.Date())

log_file <- file(log_file_name, open = "wt")

sink(log_file)

sink(log_file, type = "message")

suppressPackageStartupMessages({

  library(f2g, quietly = TRUE)
  library(finbif, quietly = TRUE)
  library(tictoc, quietly = TRUE)

})

options(
  finbif_api_url = Sys.getenv("FINBIF_API"),
  finbif_use_cache = FALSE,
  finbif_use_cache_metadata = TRUE,
  finbif_max_page_size = 250L,
  finbif_rate_limit = Inf,
  finbif_retry_times = 10,
  finbif_retry_pause_base = 2,
  finbif_retry_pause_cap = 5e3
)

if (!file.exists("config.yml")) {

  invisible(file.copy("../config.yml", "."))

}

if (!dir.exists("stage")) {

  dir.create("stage")

}

res <- tryCatch(

  {

    start_timer <- tic()

    gbif_datasets <- get_gbif_datasets()

    finbif_collections <- get_collection_ids(gbif_datasets)

    for (collection in sample(finbif_collections)) {

      Sys.setenv(R_CONFIG_ACTIVE = collection)

      timeout <- 3600 * config::get("timeout")

      if (skip_collection(collection)) next

      archive <- get_archive_path(collection)

      staged_archive <- stage_archive(archive)

      subsets <- get_subsets(collection)

      write_meta(staged_archive, subsets)

      unstage_archive(staged_archive)

      clean_occurrences(staged_archive, subsets)

      any_need_archive <- logical()

      for (subset in sample(subsets)) {

        file <- get_file_name(subset)

        media_file <- get_file_name(subset, prefix = "media")

        mod_time <- last_mod(staged_archive, file)

        subset_age <- difftime(Sys.time(), mod_time, units = "weeks")

        needs_archiving <-  subset_age > config::get("max_age_weeks")

        if (needs_archiving) {

          subset_n <- count_occurrences(subset)

          unequal <- count_occurrences(staged_archive, file) != subset_n

          trigger <- Sys.getenv("TRIGGER")

          last_mod_subset <- last_mod(subset)

          use_trigger <- trigger > last_mod_subset

          use_trigger <- isTRUE(use_trigger)

          if (use_trigger) {

            last_mod_subset <- trigger

          }

          outdated <- as.POSIXct(last_mod_subset) > mod_time

          needs_archiving <- any(unequal, outdated)

          if (needs_archiving) {

            archive_occurrences(
              staged_archive, file, media_file, subset, n = subset_n
            )

            unstage_archive(staged_archive)

          }

        }

        any_need_archive <- any(needs_archiving, any_need_archive)

        stop_timer <- toc(quiet = TRUE)

        tic()

        if (stop_timer$toc - start_timer > timeout) break

      }

      has_all_subsets <- identical(length(subsets), n_archived_subsets(archive))

      uuid <- NULL

      if (has_all_subsets) {

        registration <- get_registration(gbif_datasets, collection)

        md <- get_metadata(collection)

        arr <- identical(md[["intellectual_rights"]], "All Rights Reserved")

        if (arr) {

          message(
            sprintf(
              "WARNING [%s] Collection %s does not have an open license",
              format(Sys.time()),
              collection
            )
          )

        }

        need_metadata_upd <- last_mod(collection) > last_mod(registration)

        if (!skip_gbif(collection) && !arr) {

          if (is.null(registration)) {

            uuid <- send_gbif_dataset_metadata(md)

            send_gbif_dataset_endpoint(get_endpoint(collection), uuid)

            send_gbif_dataset_id(collection, uuid)

          } else {

            if (isTRUE(need_metadata_upd)) {

              update_gbif_dataset_metadata(md, registration)

            }

            uuid <- get_uuid(registration)

            update_gbif_dataset_endpoint(get_endpoint(collection), uuid)

          }

        }

        write_eml(staged_archive, collection, uuid, md)

        unstage_archive(staged_archive)

        publish_archive(staged_archive)

        ingest <- need_metadata_upd || any_need_archive || is.null(registration)

        if (!skip_gbif(collection) && ingest) initiate_gbif_ingestion(uuid)

      }

      stop_timer <- toc(quiet = TRUE)

      tic()

      if (stop_timer$toc - start_timer > timeout) {

        message(
          sprintf(
            "INFO [%s] Reached time limit. Job exiting", format(Sys.time())
          )
        )

        break

      }

    }

    message(sprintf("INFO [%s] Job complete", format(Sys.time())))

    "true"

  },
  error = function(e) {

    message(sprintf("ERROR [%s] %s", format(Sys.time()), e$message))

    "false"

  }
)

system2(
  "rclone",
  c(
    "sync",
    "\"archives/split\"",
    sprintf("\"default:hy-7088-finbif2gbif-%s\"", Sys.getenv("BRANCH"))
  )
)

dir.create("status", showWarnings = FALSE)

cat(res, file = "status/success.txt")

cat(format(Sys.time(), usetz = TRUE), file = "status/last-update.txt")

sink(type = "message")

sink()

file.copy(log_file_name, "logs/update-latest.txt", TRUE)
