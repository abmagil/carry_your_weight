class HomeChannel < ApplicationCable::Channel
  periodically :send_commit_hash, every: 5.seconds

  def subscribed
    puts "I am subscribed"
  end

  def unsubscribed
    stop_all_streams
    puts "I am now unsubscribed!"
  end

  def send_commit_hash
    transmit commit_document
  end

  private

    def commit_document
      {
        commit: "bd2cbd1455df71765e9efb55ea17dd1cc545924f",
        time: Date.current,
        author_lines: {
          "Liz": rand_lines(4),
          "Magil": rand_lines(5),
          "Person_3": rand_lines(3)
        }
      }
    end

    def rand_lines(base)
      rand(10) + 1 + base
    end
  # end private block
end
