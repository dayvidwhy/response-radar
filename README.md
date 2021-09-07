# Response Radar
Checks whether an address is up over time and responds to given URL's with a notification if the address is down.

## Installation
Currently using ruby 2.7.x for development so I recommend installing it with homebrew.
```bash
brew install ruby@2.7
# follow further prompts to add to your PATH
```

Then to grab the project and get it up and running.
```bash
git clone git@github.com:dayvidwhy/response-radar.git
cd response-radar
bundle install
bundle exec ruby src/server.rb
```

Starts the server at `http://localhost:4567`.

The ruby web framework Sinatra is included as a way of communicating with the running program.

## Routes
The application can be communicated with using a few routes.

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
# Stop a running radar
POST /stop
Requires {
    "id": <ID of radar worker>
}
Returns {
    "status": <Status>
}
```

```bash
# Start a stopped radar
POST /start
Requires {
    "id": <ID of radar worker>
}
Returns {
    "status": <Status>
}
```

## How it works
When the `/create` endpoint is sent a url to continuously check a worker thread is produced that allows for many addresses to be checked concurrently. When we want to stop the worker checking we end the thread.
