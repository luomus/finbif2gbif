FROM rhub/r-minimal:4.0.5-patched

RUN  apk add --no-cache --update-cache \
       --repository http://nl.alpinelinux.org/alpine/v3.11/main \
       autoconf=2.69-r2 \
       automake=1.16.1-r0 \
       curl \
  && installr -d \
      -t "autoconf automake bash libsodium-dev curl-dev linux-headers libxml2-dev" \
      -a "libsodium libxml2" \
      digest \
      httr \
      logger \
      lutz \
      plumber \
      rapidoc \
      remotes \
      tictoc \
      xml2 \
      zip

HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl -sfI -o /dev/null 0.0.0.0:8000/healthz || exit 1

RUN sed -i 's/RapiDoc/FinBIF to GBIF/g' \
      /usr/local/lib/R/library/rapidoc/dist/index.html

RUN  R -e "remotes::install_github('luomus/finbif@dev')"

COPY pkg f2g

RUN  R -e "remotes::install_local('f2g')" \
  && rm -rf f2g

ENV HOME /home/user

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY init.R /home/user/init.R
COPY api.R /home/user/api.R

RUN  mkdir -p /home/user/logs \
  && mkdir -p /home/user/archives \
  && chgrp -R 0 /home/user \
  && chmod -R g=u /home/user /etc/passwd

WORKDIR /home/user

USER 1000

EXPOSE 8000

ENTRYPOINT ["entrypoint.sh"]

CMD ["Rscript", "--vanilla", "init.R"]
