# library imports
require "sinatra/base"
require 'json'

# load our radar
require_relative './radar.rb'

# Main Sinatra class instantiates the server
class Server < Sinatra::Base
    # configure sinatra
    Server.configure do
        # sinatra traps system interupts
        # turning this off helps us stop the server
        # if one of our checking loops is still running
        disable :traps
    end
end

# Helper to setup our routes on the server and then
# provides a method to actually start the server.
class ServerHandler
    def initialize(server)
        @server = server
        @server.get "/" do
            "app is running"
        end
        
        # simple endpoint that receives a url and request type to check
        @server.post "/check" do
            check = JSON.parse(request.body.read)
        
            # check loop in new thread per request
            Thread.new {
                responseRadar = ResponseRadar.new(check["url"], check["hook"])
                responseRadar.beginChecking
            }
        
            # let the client know we have their request
            res = Hash.new
            res["status"] = "Received request to keep check."
            body (JSON.generate(res))
            status 200
        end
        
        # hook to capture a notification when an address goes down
        @server.get "/notify" do
            puts "Was notified of being down"
            status 200
        end
    end

    def start
        @server.run!
    end
end

server = ServerHandler.new(Server)
server.start
