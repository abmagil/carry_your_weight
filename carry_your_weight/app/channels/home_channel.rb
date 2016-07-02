class HomeChannel < ApplicationCable::Channel
  def subscribed
    puts "I am subscribed"
  end

  def unsubscribed
    puts "I am now unsubscribed!"
  end
end
