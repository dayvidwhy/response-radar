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

        if (params.key?("url") && params.key?("hook"))
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
        else
            # return our response
            body(JSON.generate({
                "status" => "Parameters not sent"
            }))
            status 200
        end
    end

    # starts a certain radar based on an ID
    post "/start" do
        params = JSON.parse(request.body.read)
        responseStatus = ""

        # did we receive an id?
        if params.key?("id")
            radarID = params["id"]

            if radars.key?(radarID)
                if radars[radarID].start
                    responseStatus = "Radar started"
                else
                    responseStatus = "Radar was already started"
                end
            else
                responseStatus = "ID was not valid"
            end
        else
            responseStatus = "ID not sent"
        end

        # return our status
        body(JSON.generate({
            "status" => responseStatus
        }))
        status 200
    end

    # stops a certain radar based on an ID
    post "/stop" do
        params = JSON.parse(request.body.read)
        responseStatus = ""

        # did we receive an id?
        if params.key?("id")
            radarID = params["id"]

            if radars.key?(radarID)
                if radars[radarID].stop
                    responseStatus = "Radar stopped"
                else
                    responseStatus = "Radar was alrady stopped"
                end
            else
                responseStatus = "ID was not valid"
            end
        else
            responseStatus = "ID not sent"
        end

        # return our status
        body(JSON.generate({
            "status" => responseStatus
        }))
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
