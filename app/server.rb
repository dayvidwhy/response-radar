# frozen_string_literal: true

# library imports
require 'sinatra/base'
require 'json'
require 'securerandom'

# load our radar
require_relative './radar'
require_relative '../utils/validate'

# Helper to setup our routes on the server and then
# provides a method to actually start the server.
class Server < Sinatra::Base
    set :radars, {}

    helpers do
        def radars
            self.class.radars
        end
    end

    configure do
        # sinatra traps system interupts
        # turning this off helps us stop the server
        # if one of our checking loops is still running
        disable :traps
    end

    # simple endpoint that receives a url and request type to check
    post '/create' do
        data = JSON.parse(request.body.read)

        if !data.key?('url') || !data.key?('hook')
            # return our response
            body(JSON.generate({
                'status' => 'Parameters not sent'
            }))
            halt 200
        end

        if !valid_url(data['url']) || !valid_url(data['hook'])
            # return our response
            body(JSON.generate({
                'status' => 'URLs are not valid'
            }))
            halt 200
        end

        # create and start our radar
        radar = ResponseRadar.new(data['url'], data['hook'])
        radar.start

        # store a reference
        radar_id = SecureRandom.uuid
        radars[radar_id] = radar

        # return our response
        body(JSON.generate({
            'status' => 'Okay',
            'id' => radar_id
        }))
        status 200
    end

    # stops a certain radar based on an ID
    post '/change/:action' do
        data = JSON.parse(request.body.read)

        if params['action'] != 'start' && params['action'] != 'stop'
            body(JSON.generate({
                'status' => 'Action not possible'
            }))
            halt 200
        end

        # did we receive an id?
        unless data.key?('id')
            body(JSON.generate({
                'status' => 'ID not sent'
            }))
            halt 200
        end

        radar_id = data['id']

        # was the id related to a radar?
        unless radars.key?(radar_id)
            body(JSON.generate({
                'status' => 'ID was not valid'
            }))
            halt 200
        end

        # perform the request action
        result = false
        case params['action']
        when 'stop'
            result = radars[radar_id].stop
        when 'start'
            result = radars[radar_id].start
        end

        # check status of the action
        response_status = ''
        if result
            response_status = 'Radar adjusted'
        else
            response_status = 'Radar was already adjusted'
        end

        # return our status
        body(JSON.generate({
            'status' => response_status
        }))
        status 200
    end

    # endpoint for testing
    get '/notify' do
        puts 'Was notified of being down'
        status 200
    end

    begin
        run!
    rescue Interrupt
        quit!
        radars.each do |_radar_id, radar|
            radar.stop
        end
        warn 'Process interrupted, shutting down.'
    rescue StandardError
        warn 'Other exception.'
    end
end
