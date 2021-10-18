FROM rstudio/plumber:latest

HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl -sfI -o /dev/null 0.0.0.0:8000/healthz || exit 1

RUN  install2.r \
       callr \
       config \
       covr \
       DT \
       future \
       htmltools \
       logger \
       rapidoc \
       tictoc \
       tinytest \
       xml2 \
       webfakes

RUN  sed -i 's/RapiDoc/FinBIF to GBIF/g' \
      /usr/local/lib/R/site-library/rapidoc/dist/index.html

RUN  R -e "remotes::install_github('luomus/finbif@dev')"

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
       /home/user/status

  && chgrp -R 0 /home/user \
  && chmod -R g=u /home/user /etc/passwd

COPY .Rprofile /home/user/.Rprofile

USER 1000

EXPOSE 8000

ENTRYPOINT ["entrypoint.sh"]

CMD ["Rscript", "--vanilla", "init.R"]
