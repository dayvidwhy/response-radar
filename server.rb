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
    uri = URI(url)
    begin
        res = Net::HTTP.get_response(uri)
        res.is_a?(Net::HTTPSuccess)
    rescue
        false
    end
end

# starts tracking for availability of a url
# currently checks 5 times
def beginChecking (url)
    x = 0
    up = true

    # start our checking loop
    while x < 5
        up = isResponseAvailable(url)
        break unless up
        x = x + 1
        sleep(5)
    end
    
    up
end

# sets up our routes
def init()
    get "/" do
        "app is running"
    end

    # simple endpoint that receives a url and request type to check
    post "/check" do
        # parse our request
        check = parseRequest(request)

        # check loop
        up = beginChecking(check["url"])

        # prepare our response
        res = Hash.new
        res["status"] = up ? "okay" : "down"

        # set response params
        body (JSON.generate(res))
        status 200
    end
end

# setup
init()
