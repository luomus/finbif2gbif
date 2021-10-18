# finbif2gbif

## Deploy

```
oc process -f openshift-template.yml --param-file=.env | oc create -f -
```

## Testing

```
docker-compose --file docker-compose.test.yml build
docker-compose --file docker-compose.test.yml run -u $(id -u) su
```
