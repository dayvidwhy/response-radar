# server.rb
require "sinatra"
require 'uri'
require 'net/http'
require 'json'

# util to parse input
def parseRequest (req)
    JSON.parse(req.body.read)
end

# check if a url is available with a get request
def isResponseAvailable (url)
    begin
        uri = URI(url)
        res = Net::HTTP.get_response(uri)
        res.is_a?(Net::HTTPSuccess)
    rescue
        false
    end
end

# notifies the specific hook
def notify (hook)
    uri = URI(hook)
    Net::HTTP.get_response(uri)
end

# starts tracking for availability of a url
def beginChecking (url, hook)
    while true
        up = isResponseAvailable(url)
        puts "site: #{url} is currently #{up ? "up" : "down"}"
        if !up
            notify(hook)
            break
        end
        sleep(5)
    end
end

# sets up our routes
def init()
    # configure sinatra
    configure do
        # sinatra traps system interupts
        # turning this off helps us stop the server
        # if one of our checking loops is still running
        disable :traps
    end

    get "/" do
        "app is running"
    end

    # simple endpoint that receives a url and request type to check
    post "/check" do
        check = parseRequest(request)

        # check loop in new thread per request
        Thread.new {
            beginChecking(check["url"], check["hook"])
        }

        # let the client know we have their request
        res = Hash.new
        res["status"] = "Received request to keep check."
        body (JSON.generate(res))
        status 200
    end

    # hook to capture a notification when an address goes down
    get "/notify" do
        puts "Was notified of being down"
        status 200
    end
end

# setup
init()
