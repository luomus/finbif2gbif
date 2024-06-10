# FinBIF2GBIF Bridge

FinBIF2GBIF is a software bridge between the Finnish Biodiversity Information
Facility (FinBIF) and the Global Biodiversity Information Facility (GBIF) data
registry.

This repository contains an R language based OpenShift deployment template (see
section "Deploy") to launch a container based HTTP API that serves Darwin Core
Archives of FinBIF collections. The same container is periodically deployed as
a cronjob that syncronises the archives with the FinBIF data warehouse; and the
collection metadata with the GBIF registry.

The data syncronisation configuration is controlled by the file, `config.yml`
(see section "Configure").

## Deploy

### Local

Either build directly from the `Dockerfile` or use a prebuilt image from the
GitHub container registry.

```sh
docker pull ghcr.io/luomus/finbif2gbif:latest
```

A `docker-compose` file is also included in this repository for local
deployment (see also section "Testing").

### OpenShift

Use the following to deploy to an OpenShift instance.

```sh
./oc-process.sh -f template.yml -e .env  | oc create -f -
```

Note the empty required parameters in the template file to infer the variables
needed in a `.env` file (not provided).

## Configure

The file `config.yaml` is used to configure the syncronisation of Darwin Core
Archives and GBIF metadata with the FinBIF data warehouse. The example below
enables all collections and will share title, description, language and license
metadata with the GBIF data registry. It also specifies the default set of
fields to include in all Darwin Core Archives and sets the maximum number of
rows per occurrence record text file inside the archive files. For the
collection _HR.447_ the records have been filter so that only records from the
year 2015 onwards are included.

```yaml
default:
  enabled: true
  metadata:
    title: long_name
    description: description
    license: intellectual_rights
  fields:
  - occurrenceID
  - basisOfRecord
  - eventDate
  - country
  - footprintWKT
  - geodeticDatum
  - coordinateUncertaintyInMeters
  - kingdom
  - scientificName
  - taxonRank
  nmax: 2.5e4
  filters:

HR.447:
  filters:
    date_range_ymd: ["2015-01-01", ""]
```

## Testing

A second docker-compose file is included for running unit tests. It is run on
each push to this repository via GitHub actions.

```sh
docker-compose --file docker-compose.test.yml build
docker-compose --file docker-compose.test.yml run -u $(id -u) su
```
