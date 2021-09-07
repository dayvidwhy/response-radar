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

    # simple endpoint that receives a url and request type to check
    post "/create" do
        params = JSON.parse(request.body.read)
    
        # create and start our radar
        radar = ResponseRadar.new(params["url"], params["hook"])
        radar.start

        # store a reference
        radarID = SecureRandom.uuid
        radars[radarID] = radar
    
        # return our response
        body(JSON.generate({
            "status" => "Okay",
            "id" => radarID
        }))
        status 200
    end

    # starts a certain radar based on an ID
    post "/start" do
        params = JSON.parse(request.body.read)
        radarID = params["id"]
        radars[radarID].start
        status 200
    end

    # stops a certain radar based on an ID
    post "/stop" do
        params = JSON.parse(request.body.read)
        radarID = params["id"]
        radars[radarID].stop
        status 200
    end

    # endpoint for testing
    get "/notify" do
        puts "Was notified of being down"
        status 200
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
