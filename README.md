# k6 Benchmark Playground

We often have to make technology decisions on which tool and architecture to prefer in order to serve a given use case. This project aims to provide a pre-formed playground to quickly run k6 scripts.

It is based on [Grafana's k6](https://k6.io/).

----

## Usage

First, start `influxdb` and `grafana` in background:
```sh
docker-compose up -d influxdb grafana
```

then run the k6 script defined among the use cases:
```sh
docker-compose run -e MY_ENV_VAR=my_value k6 run /use-cases/dummy-case.js 
```

Optionally, navigate `grafana`'s UI on http://localhost:3000 to fetch and visualize collected data.


## Folder structure

**use_cases**
k6 scripts that execute some tests against a specified target.

**targets**
Everything is needed to setup and teardown a target application to perform tests against.


