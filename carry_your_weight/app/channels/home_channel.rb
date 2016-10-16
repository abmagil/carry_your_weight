class HomeChannel < ApplicationCable::Channel
  COMMITTERS = ["Aaron", "Beth", "Clarence", "Denise", "Ephraim", "Florence"]

  def subscribed
    puts "I am subscribed"
    transmit commit_document
  end

  def next
    transmit commit_document
  end

  def unsubscribed
    stop_all_streams
    puts "I am now unsubscribed!"
  end

  private

    def commit_document
      random_string = (0...8).map { (65 + rand(26)).chr }.join

      committers = COMMITTERS.take(rand(COMMITTERS.length) + 1).shuffle

      authors_hash = committers.inject({}) do |memo, committer|
        memo[committer] = rand(26)
        memo
      end

      {
        commit: Digest::SHA1.hexdigest(random_string),
        time: Date.current,
        author_lines: authors_hash
      }
    end
  # end private block
end
