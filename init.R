pkgs <- c("f2g", "logger", "plumber", "rapidoc", "tictoc", "utils")

for (pkg in pkgs) {

  suppressPackageStartupMessages(
    library(pkg, quietly = TRUE, character.only = TRUE)
  )

}

log_dir <- "logs"

log_file <- tempfile("plumber_", log_dir, ".log")

logger::log_appender(
  logger::appender_tee(log_file)
)

convert_empty <- function(x) switch(paste0(".", x), . = "-", x)

p <- plumber::plumb("api.R")

p$registerHooks(
  list(
    preroute = function() tictoc::tic(),
    postroute = function(req, res) {

      end <- tictoc::toc(quiet = TRUE)

      log_fn <- logger::log_info

      if (res$status >= 400L) log_fn <- logger::log_error

      log_fn(
        paste0(
          '{convert_empty(req$REMOTE_ADDR)} ',
          '"{convert_empty(req$HTTP_USER_AGENT)}" ',
          '{convert_empty(req$HTTP_HOST)} ',
          '{convert_empty(req$REQUEST_METHOD)} ',
          '{convert_empty(req$PATH_INFO)} ',
          '{convert_empty(res$status)} ',
          '{round(end$toc - end$tic, digits = getOption("digits", 5L))}'
        )
      )

    }
  )
)

p$run(host = "0.0.0.0", port = 8000L, quiet = TRUE)
