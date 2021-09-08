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
        data = JSON.parse(request.body.read)

        if (!data.key?("url") || !data.key?("hook"))
            # return our response
            body(JSON.generate({
                "status" => "Parameters not sent"
            }))
            halt 200
        end

        # create and start our radar
        radar = ResponseRadar.new(data["url"], data["hook"])
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

    # stops a certain radar based on an ID
    post "/change/:action" do
        data = JSON.parse(request.body.read)

        if params["action"] != "start" && params["action"] != "stop"
            body(JSON.generate({
                "status" => "Action not possible"
            }))
            halt 200
        end

        # did we receive an id?
        if !data.key?("id")
            body(JSON.generate({
                "status" => "ID not sent"
            }))
            halt 200
        end

        radarID = data["id"]

        # was the id related to a radar?
        if !radars.key?(radarID)
            body(JSON.generate({
                "status" => "ID was not valid"
            }))
            halt 200
        end

        # perform the request action
        result = false
        if params["action"] == "stop"
            result = radars[radarID].stop
        elsif params["action"] == "start"
            result = radars[radarID].start
        end
        
        # check status of the action
        responseStatus = ""
        if result
            responseStatus = "Radar adjusted"
        else
            responseStatus = "Radar was already adjusted"
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
