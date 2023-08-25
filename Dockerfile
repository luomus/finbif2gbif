FROM ghcr.io/luomus/base-r-image@sha256:db3ad26dc6edfdaed2611f87b948cb3ee9fd41cf9fab8dc701508f5c70906020

ENV STATUS_DIR="var/status"
ENV LOG_DIR="var/logs"

COPY combine-dwca.sh /usr/local/bin/combine-dwca.sh
COPY renv.lock /home/user/renv.lock
COPY api.R /home/user/api.R
COPY finbif2gbif.R /home/user/finbif2gbif.R
COPY config.yml /home/user/config.yml
COPY favicon.ico /home/user/favicon.ico
COPY DESCRIPTION /home/user/DESCRIPTION
COPY inst /home/user/inst
COPY man /home/user/man
COPY NAMESPACE /home/user/NAMESPACE
COPY R /home/user/R
COPY tests /home/user/tests

RUN  R -e "renv::restore()"
RUN  R -e 'remotes::install_local(dependencies = FALSE, upgrade = FALSE)' \
  && permissions.sh
