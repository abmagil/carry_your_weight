require 'rugged'
require 'ruby-progressbar'
require 'mongo'

IGNORE_FILES = ['.gitignore', 'Gemfile.lock', '.project', 'LICENSE']
IGNORE_DIRS = ['bin/', 'pkg/']


# Path to a local git repo
repo = Rugged::Repository.new(ARGV[0])
# "~/project_folder/project.git" => "project"
project_name = repo.workdir.split("/").last

# Instantiate DB and collection connection
collection = Mongo::Client.new([ '127.0.0.1:27017' ], :database => "carry_your_weight")[project_name]

# Instantiate progress bar, ending at the total number of commits
progress_bar = ProgressBar.create(total: Rugged::Walker.walk(repo, show: repo.head.target).count)

# Walk every commit on master, starting at the last one
Rugged::Walker.walk(repo, show: repo.head.target, sort: Rugged::SORT_DATE) do |commit|
  # Count the files
  commit.tree.walk_blobs(:postorder) do |root, entry|
    next if IGNORE_DIRS.include? root
    next if IGNORE_FILES.include? entry[:name]

    file_path = root + entry[:name]

    # having been handed a file
    blame = Rugged::Blame.new(repo, file_path, newest_commit: commit)

    # [{"julian" => [hunk]}]
    author_hunks = blame.group_by{|hunk| hunk[:final_signature][:name]}

    author_to_lines = {}
    author_hunks.each do |author, hunks|
      author_to_lines[author] = hunks.reduce(0) do |memo, hunk|
        memo += hunk[:lines_in_hunk]
      end
    end

    author_to_lines.each do |author, lines|
      # author_to_lines will be ["julian" => 15, "aaron" => 10]
      data_hash = {
        commit: commit.oid,
        filename: file_path,
        date: commit.time,
        author: author,
        lines: lines
      }

      # Change me to a insert_many([...]) for performance reasons
      # array can just be a transformed author_hunks, simplifying this code so
      # that we insert_many once for each commit
      collection.insert_one(data_hash)
    end
  end
  progress_bar.increment

end

