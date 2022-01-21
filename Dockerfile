FROM rstudio/plumber:latest

RUN  install2.r -e -s \
       callr \
       config \
       covr \
       digest \
       DT \
       EML \
       htmltools \
       httr \
       logger \
       lutz \
       rapidoc \
       remotes \
       tictoc \
       tinytest \
       V8 \
       webfakes \
       withr \
       xml2 \
       yaml

RUN  apt-get update -qq \
  && apt-get install -y \
       libjq-dev \
       nano \
  && apt-get autoremove -y \
  && apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/*

RUN  install2.r -e -r cran.r-project.org \
       jqr

HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl -sfI -o /dev/null 0.0.0.0:8000/healthz || exit 1

RUN  echo "R_ZIPCMD=${R_ZIPCMD-'/usr/bin/zip'}" >> /usr/local/lib/R/etc/Renviron

RUN  sed -i 's/RapiDoc/FinBIF to GBIF/g' \
      /usr/local/lib/R/site-library/rapidoc/dist/index.html

RUN  R -e "remotes::install_github('luomus/finbif@a383bbd0')"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY combine-dwca.sh /usr/local/bin/combine-dwca.sh
COPY init.R /home/user/init.R
COPY api.R /home/user/api.R
COPY finbif2gbif.R /home/user/finbif2gbif.R
COPY config.yml /home/user/config.yml
COPY favicon.ico /home/user/favicon.ico
COPY robots.txt /home/user/robots.txt
COPY pkg /home/user/f2g

ENV  HOME /home/user
ENV  OPENBLAS_NUM_THREADS 1

WORKDIR /home/user

RUN  R -e "remotes::install_local('f2g', NULL, FALSE, 'never')" \
  && mkdir -p \
       /home/user/archives \
       /home/user/coverage \
       /home/user/var \
       /home/user/stage \
  && chgrp -R 0 /home/user \
  && chmod -R g=u /home/user /etc/passwd

COPY .Rprofile /home/user/.Rprofile

USER 1000

EXPOSE 8000

ENTRYPOINT ["entrypoint.sh"]

CMD ["Rscript", "--vanilla", "init.R"]
