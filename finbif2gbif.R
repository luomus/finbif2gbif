finbif_collections <- get_collection_ids()

gbif_datasets <- get_gbif_datasets()

for (collection in sample(finbif_collections)) {

  Sys.setenv(R_CONFIG_ACTIVE = collection)

  if (skip_collection(collection)) next

  archive <- get_archive_path(collection)

  subsets <- get_subsets(collection)

  write_meta(archive, subsets)

  clean_occurrences(archive, subsets)

  for (subset in sample(subsets)) {

    file <- get_file_name(subset)

    unequal <- count_occurrences(archive, file) != count_occurrences(subset)

    outdated <- last_mod(archive, file) > last_mod(subset)

    if (unequal || outdated) {

      archive_occurrences(archive, file, subset)

    }

  }

  registration <- get_registration(gbif_datasets, collection)

  if (is.null(registration)) {

    uuid <- send_gbif_dataset_metadata(get_metadata(collection))

    send_gbif_dataset_endpoint(get_endpoint(collection), uuid)

    send_gbif_dataset_id(collection, uuid)

  } else if (last_mod(collection) > last_mod(registration)) {

    update_gbif_dataset_metadata(get_metadata(collection), registration)

  }

}
