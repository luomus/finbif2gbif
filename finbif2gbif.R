dir.create("logs", showWarnings = FALSE)

log_file_name <- sprintf("logs/update-%s.txt", Sys.Date())

log_file <- file(log_file_name, open = "wt")

sink(log_file)

sink(log_file, type = "message")

if (!file.exists("config.yml")) {

  invisible(file.copy("../config.yml", "."))

}

if (!dir.exists("stage")) {

  dir.create("stage")

}

res <- tryCatch(

  {

    start_timer <- tic()

    source("../update_collections.R")

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
