FROM ghcr.io/luomus/base-r-image@sha256:1284c451bd7c894bc77aa728087648562a9c10a203e688cf81a317aaa6f93de5

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
