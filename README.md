![Build and tests](https://github.com/Kevin-De-Koninck/pollen-parser/workflows/Build%20and%20tests/badge.svg)
![Push Docker container](https://github.com/Kevin-De-Koninck/pollen-parser/workflows/Push%20Docker%20container/badge.svg)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=Kevin-De-Koninck_pollen-parser&metric=alert_status)](https://sonarcloud.io/dashboard?id=Kevin-De-Koninck_pollen-parser)
[![Maintainability](https://api.codeclimate.com/v1/badges/70d90421995e8a8dcf64/maintainability)](https://codeclimate.com/github/Kevin-De-Koninck/pollen-parser/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/70d90421995e8a8dcf64/test_coverage)](https://codeclimate.com/github/Kevin-De-Koninck/pollen-parser/test_coverage)

# Pollen-parser

## How to build and run

### Dev container

``` bash
./build.sh -p dev
./run.sh
```

### Prod container

``` bash
./build.sh -p prod -v 'v0.0.1'
./run.sh -v 'v0.0.1'
```

## Data source

The source of the concentration levels can be found on [meteo.be](https://www.meteo.be/nl/weer/verwachtingen/stuifmeelallergie-en-hooikoorts) page.

## Pushover keys

This project requires the PushOver keys to be present in a YAML file that is volume mounted inside the container. An example config file:

``` yaml
pushover:
  API_token: 'abcdefghijklmnopqrstuvwxyz0123'
  user_key: 'abcdefghijklmnopqrstuvwxyz0123'
```





