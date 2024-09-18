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

update_collection <- function(
  collection,
  timeout = 3600,
  start_timer = tictoc::tic(),
  gbif_datasets = f2g::get_gbif_datasets()
) {

  force(start_timer)

  archive <- f2g::get_archive_path(collection)

  staged_archive <- f2g::stage_archive(archive)

  subsets <- f2g::get_subsets(collection)

  f2g::write_meta(staged_archive, subsets)

  f2g::unstage_archive(staged_archive)

  f2g::clean_occurrences(staged_archive, subsets)

  any_need_archive <- logical()

  for (subset in sample(subsets)) {

    file <- f2g::get_file_name(subset)

    media_file <- f2g::get_file_name(subset, prefix = "media")

    mod_time <- f2g::last_mod(staged_archive, file)

    subset_age <- difftime(Sys.time(), mod_time, units = "weeks")

    needs_archiving <- subset_age > config::get("max_age_weeks")

    if (needs_archiving) {

      subset_n <- f2g::count_occurrences(subset)

      unequal <- f2g::count_occurrences(staged_archive, file) != subset_n

      trigger <- Sys.getenv("TRIGGER")

      last_mod_subset <- f2g::last_mod(subset)

      use_trigger <- trigger > last_mod_subset

      use_trigger <- isTRUE(use_trigger)

      if (use_trigger) {

        last_mod_subset <- trigger

      }

      outdated <- as.POSIXct(last_mod_subset) > mod_time

      needs_archiving <- any(unequal, outdated)

      if (needs_archiving) {

        f2g::archive_occurrences(
          staged_archive, file, media_file, subset, n = subset_n
        )

        f2g::unstage_archive(staged_archive)

      }

    }

    any_need_archive <- any(needs_archiving, any_need_archive)

    stop_timer <- tictoc::toc(quiet = TRUE)

    tictoc::tic()

    if (stop_timer$toc - start_timer > timeout) break

  }

  has_all_subsets <- identical(
    length(subsets), f2g::n_archived_subsets(archive)
  )

  uuid <- NULL

  if (has_all_subsets) {

    registration <- f2g::get_registration(gbif_datasets, collection)

    md <- f2g::get_metadata(collection)

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

    need_metadata_upd <- f2g::last_mod(collection) > f2g::last_mod(registration)

    if (!skip_gbif(collection) && !arr) {

      if (is.null(registration)) {

        uuid <- f2g::send_gbif_dataset_metadata(md)

        f2g::send_gbif_dataset_endpoint(f2g::get_endpoint(collection), uuid)

        f2g::send_gbif_dataset_id(collection, uuid)

      } else {

        if (isTRUE(need_metadata_upd)) {

          f2g::update_gbif_dataset_metadata(md, registration)

        }

        uuid <- f2g::get_uuid(registration)

        f2g::update_gbif_dataset_endpoint(f2g::get_endpoint(collection), uuid)

      }

    }

    f2g::write_eml(staged_archive, collection, uuid, md)

    f2g::unstage_archive(staged_archive)

    f2g::publish_archive(staged_archive)

    ingest <- need_metadata_upd || any_need_archive || is.null(registration)

    if (!skip_gbif(collection) && ingest) f2g::initiate_gbif_ingestion(uuid)

  }

  invisible(NULL)

}
