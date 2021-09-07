# library imports
require 'uri'
require 'net/http'

# Periodically checks whether an address is available
class ResponseRadar
    def initialize(url, hook)
        @url = url
        @hook = hook
        @radar
    end

    # starts our worker thread
    def start
        # return early if thread exists
        if @radar != nil
            return
        end

        # spawn our worker
        @radar = Thread.new {
            loop {
                up = isResponseAvailable
                puts "site: #{@url} is currently #{up ? "up" : "down"}"
                if !up
                    notify
                end
                sleep(5)
            }
        }
    end

    # stops the worker thread
    def stop
        # return early if no worker
        if @radar == nil
            return
        end

        # end our worker
        @radar.exit
        @radar = nil
    end

    # check if a url is available with a get request
    def isResponseAvailable
        begin
            uri = URI(@url)
            res = Net::HTTP.get_response(uri)
            res.is_a?(Net::HTTPSuccess)
        rescue
            false
        end
    end

    # notifies the specific hook
    def notify
        uri = URI(@hook)
        Net::HTTP.get_response(uri)
    end
end
