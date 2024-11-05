# docker manifest inspect ghcr.io/luomus/base-r-image:main -v | jq '.Descriptor.digest'
FROM ghcr.io/luomus/base-r-image@sha256:39e6fe1a210c04731a6dbd200efbdcc686ba6c688f149f4365ed07f5cea49822

COPY renv.lock /home/user/renv.lock

RUN R -s -e "renv::restore()"

COPY combine-dwca.sh /usr/local/bin/combine-dwca.sh
COPY api.R /home/user/api.R
COPY finbif2gbif.R /home/user/finbif2gbif.R
COPY update_collections.R /home/user/update_collections.R
COPY update_collection.R /home/user/update_collection.R
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
