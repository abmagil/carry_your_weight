class HomeChannel < ApplicationCable::Channel
  def subscribed
    puts "I am subscribed"
  end

  def unsubscribed
    stop_all_streams
    puts "I am now unsubscribed!"
  end

  def ping
    transmit "end"
  end
end
