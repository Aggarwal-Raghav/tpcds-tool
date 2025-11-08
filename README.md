# tpc-ds

This project contains sql queries and script to generate data in local setup with tpc-ds v4.0.0 spec

Dockerfile is inspired from https://github.com/zabetak/tpcds-tools


# To build a single query from template
```
docker run --rm -v tpcds-queries:/tmp tpc-ds dsqgen \
    -TEMPLATE query1.tpl \
    -DIRECTORY ../query_templates \
    -DIALECT netezza \
    -SCALE 10 \
    -OUTPUT_DIR /tmp
```

# To build all queries
```
docker run --rm -v tpcds-queries:/tmp tpc-ds dsqgen \
    -INPUT ../query_templates/templates.lst \
    -DIRECTORY ../query_templates \
    -DIALECT netezza \
    -SCALE 10 \
    -QUALIFY Y \
    -OUTPUT_DIR /tmp
```
