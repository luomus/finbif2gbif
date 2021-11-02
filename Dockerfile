FROM ghcr.io/r-hub/r-minimal/r-minimal:4.1.1

RUN  apk add --no-cache --update-cache \
       --repository http://nl.alpinelinux.org/alpine/v3.12/main \
       curl \
       zip \
       tzdata \
  && export TZDIR=/usr/share/zoneinfo \
  && installr -d \
      -t "curl-dev libxml2-dev linux-headers" \
      -a "libxml2" \
      callr \
      config \
      covr \
      digest \
      DT \
      future \
      htmltools \
      httr \
      logger \
      lutz \
      rapidoc \
      remotes \
      tictoc \
      tinytest \
      webfakes \
      withr \
      xml2 \
      yaml

RUN  apk add --no-cache --update-cache \
       --repository http://nl.alpinelinux.org/alpine/v3.12/main \
       autoconf=2.69-r2 \
       automake=1.16.2-r0 \
       curl-dev \
       g++ \
  && curl -o httpuv_1.6.3.tar.gz \
          -L https://api.github.com/repos/rstudio/httpuv/tarball/v1.6.3 \
  && mkdir -p httpuv \
  && tar xf httpuv_1.6.3.tar.gz -C httpuv --strip-components 1 \
  && rm -rf httpuv_1.6.3.tar.gz \
  && sed -i '67,68d' httpuv/src/Makevars \
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

RUN  R -e "remotes::install_github('luomus/finbif@22a2f73d')"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY init.R /home/user/init.R
COPY api.R /home/user/api.R
COPY finbif2gbif.R /home/user/finbif2gbif.R
COPY config.yml /home/user/config.yml
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
