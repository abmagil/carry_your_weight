class HomeChannel < ApplicationCable::Channel
  periodically :send_commit_hash, every: 5.seconds

  COMMITTERS = ["Aaron", "Beth", "Clarence", "Denise", "Ephraim", "Florence"]

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
      random_string = (0...8).map { (65 + rand(26)).chr }.join

      committers = COMMITTERS.take(rand(COMMITTERS.length))

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
