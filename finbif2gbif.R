res <- tryCatch(

  {

    timeout <- as.numeric(Sys.getenv("TIMEOUT"))

    start_timer <- tic()

    finbif_collections <- get_collection_ids()

    gbif_datasets <- get_gbif_datasets()

    for (collection in sample(finbif_collections)) {

      Sys.setenv(R_CONFIG_ACTIVE = collection)

      if (skip_collection(collection)) next

      archive <- get_archive_path(collection)

      archive <- stage_archive(archive)

      subsets <- get_subsets(collection)

      write_meta(archive, subsets)

      clean_occurrences(archive, subsets)

      any_need_archiving <- logical()

      for (subset in subsets) {

        file <- get_file_name(subset)

        subset_n <- count_occurrences(subset)

        unequal <- count_occurrences(archive, file) != subset_n

        outdated <- last_mod(subset) > last_mod(archive, file)

        needs_archiving <- any(unequal, outdated)

        if (needs_archiving) {

          archive_occurrences(archive, file, subset, n = subset_n)

        }

        any_need_archiving <- any(needs_archiving, any_need_archiving)

      }

      registration <- get_registration(gbif_datasets, collection)

      md <- get_metadata(collection)

      need_metadata_upd <- last_mod(collection) > last_mod(registration)

      if (!skip_gbif(collection)) {

        if (is.null(registration)) {

          uuid <- send_gbif_dataset_metadata(md)

          send_gbif_dataset_endpoint(get_endpoint(collection), uuid)

          send_gbif_dataset_id(collection, uuid)

        } else {

          if (need_metadata_upd) {

            update_gbif_dataset_metadata(md, registration)

          }

          uuid <- get_uuid(registration)

        }

        write_eml(archive, collection, uuid, md)

      }

      publish_archive(archive, subsets)

      if (!skip_gbif(collection) && (need_metadata_upd || any_need_archiving)) {

        initiate_gbif_ingestion(uuid)

      }

      stop_timer <- toc(quiet = TRUE)

      if (stop_timer$toc - start_timer > 60 * 60 * timeout) {

        message(
          sprintf("INFO [%s] Reached time limit. Job exiting", Sys.time())
        )

        break

      }

      tic()

    }

    message(sprintf("INFO [%s] Job complete", Sys.time()))

    "true"

  },
  error = function(e) {
    message(sprintf("ERROR [%s] %s", Sys.time(), e$message))
    "false"
  }
)

if (!dir.exists("logs/status")) dir.create("logs/status", recursive = TRUE)
cat(res, file = "logs/status/success.txt")
cat(format(Sys.time(), usetz = TRUE), file = "logs/status/last-update.txt")
