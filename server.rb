# server.rb
require "sinatra"
require 'uri'
require 'net/http'
require 'json'

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

# sets up our routes
def init()
    get "/" do
        "app is running"
    end

    # simple endpoint that receives a url and request type to check
    post "/check" do
        check = JSON.parse request.body.read
        up = isResponseAvailable check["url"]
        res = Hash.new
        res["status"] = up ? "okay" : "down"
        body (JSON.generate(res))
        status 200
    end
end

# setup
init()
