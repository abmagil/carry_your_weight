require 'rugged'
require 'mongo'


IGNORE_FILES = ['.gitignore', 'Gemfile.lock', '.project', 'LICENSE']
IGNORE_DIRS = ['bin/', 'pkg/']


# Path to a local git repo
repo = Rugged::Repository.new(ARGV[0])
# "~/project_folder/project.git" => "project"
project_name = repo.workdir.split("/").last

# Instantiate DB and collection connection
collection = Mongo::Client.new([ '127.0.0.1:27017' ], :database => "carry_your_weight")[project_name]

# Get the HEAD commit from master
master_head = repo.branches.find{|br| br.name == "master"}.target

# Walk every commit on master, starting at the last one
Rugged::Walker.walk(repo, show: master_head, sort: Rugged::SORT_DATE) do |commit|

  # an unfortunately imperative style, required by the methods available
  commit_digest = []
  commit.tree.walk_blobs(:postorder) do |root, entry|
    next if IGNORE_DIRS.include? root
    next if IGNORE_FILES.include? entry[:name]

    file_path = root + entry[:name]
    blame = Rugged::Blame.new(repo, file_path, newest_commit: commit)

    # [{"julian" => [hunk, hunk]}, {"aaron" => [hunk, hunk]}]
    blame.group_by{|hunk| hunk[:final_signature][:name]}.each do |author, hunks|
      
      # Add to insertion batch
      commit_digest << {
        commit: commit.oid,
        filename: file_path,
        date: commit.time,
        author: author,
        lines: hunks.reduce(0) {|memo, hunk| hunk[:lines_in_hunk]}
      }
    end
  end
  collection.insert_many(commit_digest)

end

