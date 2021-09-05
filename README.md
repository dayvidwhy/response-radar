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
bundle exec ruby server.rb
```

To start the web server listening on port 4567. The ruby web framework Sinatra is included as a way of communicating with the running program.
