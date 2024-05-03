# docker manifest inspect ghcr.io/luomus/base-r-image:main -v | jq '.Descriptor.digest'
FROM ghcr.io/luomus/base-r-image@sha256:c93c6f4e1fbf174d4cfd140689b1ab97bff269f2ecd25e4277d0e0d5b657fb20

ENV FINBIF_USER_AGENT=https://github.com/luomus/finbif2gbif
ENV STATUS_DIR="var/status"
ENV LOG_DIR="var/logs"

COPY renv.lock /home/user/renv.lock

RUN R -s -e "renv::restore()"

COPY combine-dwca.sh /usr/local/bin/combine-dwca.sh
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
COPY .Rbuildignore /home/user/.Rbuildignore

RUN R CMD INSTALL .
RUN permissions.sh
