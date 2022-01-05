FROM ghcr.io/r-hub/r-minimal/r-minimal:4.1.2

RUN  apk add --no-cache --update-cache \
       --repository http://nl.alpinelinux.org/alpine/v3.14/main \
       curl \
       zip \
       tzdata \
  && export TZDIR=/usr/share/zoneinfo \
  && DOWNLOAD_STATIC_LIBV8=1 installr -d -t curl-dev V8 \
  && installr -d \
      -t "curl-dev jq-dev libxml2-dev linux-headers" \
      -a "libxml2 jq" \
      callr \
      config \
      covr \
      digest \
      DT \
      EML \
      htmltools \
      httr \
      later \
      logger \
      lutz \
      promises \
      rapidoc \
      remotes \
      tictoc \
      tinytest \
      webfakes \
      withr \
      xml2 \
      yaml

RUN  apk add --no-cache --update-cache \
       --repository http://nl.alpinelinux.org/alpine/v3.14/main \
       autoconf=2.71-r0 \
       automake=1.16.3-r0 \
       curl-dev \
       g++ \
  && curl -o httpuv_1.6.5.tar.gz \
          -L https://api.github.com/repos/rstudio/httpuv/tarball/v1.6.5 \
  && mkdir -p httpuv \
  && tar xf httpuv_1.6.5.tar.gz -C httpuv --strip-components 1 \
  && rm -rf httpuv_1.6.5.tar.gz \
  && sed -i '77,78d' httpuv/src/Makevars \
  && R -e "remotes::install_local('httpuv', NULL, FALSE, 'never')" \
  && rm -rf httpuv \
  && installr -d \
      -t "autoconf automake bash curl-dev g++ libsodium-dev linux-headers" \
      -a "libsodium" \
      plumber

HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl -sfI -o /dev/null 0.0.0.0:8000/healthz || exit 1

RUN  echo "R_ZIPCMD=${R_ZIPCMD-'/usr/bin/zip'}" >> /usr/local/lib/R/etc/Renviron

RUN  sed -i 's/RapiDoc/FinBIF to GBIF/g' \
      /usr/local/lib/R/library/rapidoc/dist/index.html

RUN  R -e "remotes::install_github('luomus/finbif@830e5ea9')"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY combine-dwca.sh /usr/local/bin/combine-dwca.sh
COPY init.R /home/user/init.R
COPY api.R /home/user/api.R
COPY finbif2gbif.R /home/user/finbif2gbif.R
COPY config.yml /home/user/config.yml
COPY config-dev.yml /home/user/config-dev.yml
COPY favicon.ico /home/user/favicon.ico
COPY pkg /home/user/f2g

ENV  HOME /home/user
ENV  OPENBLAS_NUM_THREADS 1

WORKDIR /home/user

RUN  R -e "remotes::install_local('f2g', NULL, FALSE, 'never')" \
  && mkdir -p \
       /home/user/archives \
       /home/user/coverage \
       /home/user/logs \
       /home/user/stage \
  && chgrp -R 0 /home/user \
  && chmod -R g=u /home/user /etc/passwd

COPY .Rprofile /home/user/.Rprofile

USER 1000

EXPOSE 8000

ENTRYPOINT ["entrypoint.sh"]

CMD ["Rscript", "--vanilla", "init.R"]
