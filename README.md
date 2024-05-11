# Response Radar

Checks whether an address is up over time and responds to given URL's with a notification if the address is down.

## Getting started

Install the project.

```bash
git clone git@github.com:dayvidwhy/response-radar.git
cd response-radar
```

## Running the server

Install ruby using homebrew on MacOS or start the provided containers.

With homebrew:
```bash
brew install ruby@3.3
bundle install
bundle exec ruby app/server.rb
```

Alternatively startup the docker container.

```bash
docker-compose up --build
docker exec -it response-radar-app bash
bundle exec ruby app/server.rb
```

Starts the server at `http://localhost:4567`.

The ruby web framework Sinatra is used as a way of communicating with the running program.

## Linting
Rubocop is included as a way of style checking the project.
```bash
bundle exec rubocop
```

## Routes
The application can be communicated with using these routes.

```bash
# Start a new radar
POST /create
Requires {
    "url": <Url to check>,
    "hook": <Url to notify>
}
Returns {
    "status": <Status>
    "id": <ID of radar worker>
}
```

```bash
# Adjust a running radar
POST /change/:<stop|start>
Requires {
    "id": <ID of radar worker>
}
Returns {
    "status": <Status>
}
```


## How it works

When the `/create` endpoint is sent a url to continuously check a worker thread is produced that allows for many addresses to be checked concurrently. When we want to stop the worker checking we end the thread.
