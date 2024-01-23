# Container Startup Synchronization #

This repository has examples of container startup synchronization issues, and respective solutions.

It has been created as support material for a blog post on the matter. When the blog goes live, a
hyperlink will be added here.

This project is inspired on [TorizonOSBuildStatus](https://github.com/leograba/TorizonOSBuildStatus).

## How to Use ##

To (re)-start an example from scratch, enter the corresponding directory and run compose:

```bash
exNumber=0
cd example${exNumber}
docker-compose down && docker volume rm example${exNumber}_grafana-storage example${exNumber}_influxdb-storage; docker-compose up --timestamps --force-recreate --pull always
```

## List of Examples ##

- [example0](./example0/): the base example, where all containers start in parallel without any kind of synchronization.
In this example, the Chromium container crashes and the application fails to write into InfluxDB.
- [example1](./example1/): the first synchronous example, fixing the previously found issues.
A new issue is discovered, where Chromium starts before the webapp is available.
- [example2](./example2/): the final synchronous example, where Chromium startup is delayed so the webapp is loaded on
the first try.
