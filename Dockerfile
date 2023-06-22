FROM ghcr.io/luomus/base-r-image@sha256:3f79dd09c0034db0ee4b8de4fe60d832a483408900b1e9d60b1729f2c6b157df

COPY combine-dwca.sh /usr/local/bin/combine-dwca.sh
COPY renv.lock /home/user/renv.lock
COPY api.R /home/user/api.R
COPY finbif2gbif.R /home/user/finbif2gbif.R
COPY config.yml /home/user/config.yml
COPY favicon.ico /home/user/favicon.ico
COPY pkg /home/user/pkg

RUN R -e "renv::restore()" \
 && sed -i 's/RapiDoc/FinBIF to GBIF/g' \
    `R --slave -e "cat(.libPaths()[[1]])"`/rapidoc/dist/index.html \
 && mkdir -p \
    /home/user/var /home/user/coverage /home/user/archives /home/user/stage \
 && chgrp -R 0 /home/user \
 && chmod -R g=u /home/user /etc/passwd

ENV STATUS_DIR="var/status"
ENV LOG_DIR="var/logs"
