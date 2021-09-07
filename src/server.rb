# library imports
require "sinatra/base"
require 'json'
require 'securerandom'

# load our radar
require_relative './radar.rb'

# Helper to setup our routes on the server and then
# provides a method to actually start the server.
class Server < Sinatra::Base
    set :radars, Hash.new

    helpers do
        def radars; self.class.radars; end
    end

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
        params = JSON.parse(request.body.read)
    
        # create and start our radar
        radar = ResponseRadar.new(params["url"], params["hook"])
        radar.start

        # store a reference
        radarID = SecureRandom.uuid
        radars[radarID] = radar
    
        # let the client know we have their request
        res = {
            "status" => "Received request to keep check.",
            "id" => radarID
        }

        # return our response
        body(JSON.generate(res))
        status 200
    end
    
    # hook to capture a notification when an address goes down
    get "/notify" do
        puts "Was notified of being down"
        status 200
    end

    # stops a certain radar based on an ID
    post "/stop" do
        params = JSON.parse(request.body.read)

        radarID = params["id"]

        radars[radarID].stop
    end

    begin
        run!
    rescue Interrupt => e
        quit!
        radars.each do |radarID, radar|
            radar.stop
        end
        STDERR.puts "Process interrupted, shutting down."
    rescue
        STDERR.puts "Other exception."
    end
end
