# README

## Ruby version

see [.ruby-version](.ruby-version)

## Database creation

with postgres running:
`bundle exec rails db:create`

## Database initialization

`bundle exec rails db:create`

## How to run the test suite

`bundle exec rspec`

## Run the server

`bundle exec rails s`

or with docker:

`docker-compose up`

all previous comands can be run inside the server container with `docker-compose exec app bash`

## Endpoints

### traces

`POST /traces`

expects the following json structure:

```json
{
  service: "test_service",
  service_version: "0.0.1",
  request: { ... }, # any json object
  response: { ... }, # any json object
  request_ts: 123456789.5, # unixtimestamp in seconds, can be in microsecond accuracy
  response_ts: 123456791.5 # unixtimestamp in seconds, can be in microsecond accuracy
}
```

`GET /traces?[newer_than=<timestamp: iso8601-string>][&limit=<max:int,default=1000>][&service=<service.name:string>[&service_version=<version: string>]]`

if none of the query params are given, it returns all traces

`newer_than` selects the traces that are newer than the given timestamp.
The `request_ts` from a previous `GET /traces` can be used here for pagination.

`limit` limits the amount of traces returned to the given integer. Can be used together with `newer_than` for pagination.

`service` filters the traces by a specific service.

`service_version` filters the traces by a specifc service-version. Can only be supplied if `service` is also supplied.

### services

`GET /services`

returns all services known to traceo

`GET /service_versions`

returns all service versions known to traceo
