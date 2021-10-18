# finbif2gbif

## Deploy

```
oc process -f openshift-template.yml --param-file=.env | oc create -f -
```
