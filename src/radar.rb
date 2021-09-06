# library imports
require 'uri'
require 'net/http'

# Periodically checks whether an address is available
class ResponseRadar
    def initialize(url, hook)
        @url = url
        @hook = hook
    end

    # starts tracking for availability of a url
    def beginChecking ()
        while true
            up = isResponseAvailable
            puts "site: #{@url} is currently #{up ? "up" : "down"}"
            if !up
                notify
            end
            sleep(5)
        end
    end

    # check if a url is available with a get request
    def isResponseAvailable ()
        begin
            uri = URI(@url)
            res = Net::HTTP.get_response(uri)
            res.is_a?(Net::HTTPSuccess)
        rescue
            false
        end
    end

    # notifies the specific hook
    def notify ()
        uri = URI(@hook)
        Net::HTTP.get_response(uri)
    end
end
