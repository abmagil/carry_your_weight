
# app.rb
# require 'thin'
require 'sinatra/base'
require 'em-websocket'
require './read_script'

module CarryYourWeight
  class Server < Sinatra::Base
    get '/' do
      erb :index
    end

  end
end

EventMachine.run do

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      ws.send "Connected to #{handshake.path}."
    end

    ws.onclose do
      ws.send "Closed."
      EM.stop
    end

    ws.onmessage do |msg|
      puts "msg: #{msg}"
      ws.send "Received Message: #{msg}"
    end
  end

  CarryYourWeight::Server.run!
end

