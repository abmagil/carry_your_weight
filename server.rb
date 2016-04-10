require 'eventmachine'
require 'em-websocket'
require 'sinatra/base'
require 'thin'


# This example shows you how to embed Sinatra into your EventMachine
# application. This is very useful if you're application needs some
# sort of API interface and you don't want to use EM's provided
# web-server.

def run(opts)

  # Start he reactor
  EM.run do

    # define some defaults for our app
    server  = opts[:server] || 'thin'
    host    = opts[:host]   || '0.0.0.0'
    port    = opts[:port]   || '4567'
    web_app = opts[:app]

    dispatch = Rack::Builder.app do
      map '/' do
        run web_app
      end
    end

    # Start the web server. Note that you are free to run other tasks
    # within your EM instance.
    Rack::Server.start({
      app:    dispatch,
      server: server,
      Host:   host,
      Port:   port,
      signals: false,
    })

    EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
      ws.onopen do |handshake|
        ws.send "Connected to #{handshake.path}."
      end

      ws.onmessage do |msg|
        puts "msg: #{msg}"
        q = EM::Queue.new
        q.push('one', 'two', 'three')
        3.times do
          q.pop { |wrd| ws.send(wrd) }
        end
      end
      
      ws.onclose do
        ws.send "Closed."
        EM.stop
      end

    end
  end
end

# Our simple hello-world app
module CarryYourWeight
  class Server < Sinatra::Base
    # threaded - False: Will take requests on the reactor thread
    #            True:  Will queue request for background thread
    configure do
      set :threaded, false
    end

    # Request runs on the reactor thread (with threaded set to false)
    get '/' do
      erb :index
    end
  end
end

# start the application
run app: CarryYourWeight::Server.new
