require 'rugged'

IGNORE_FILES = ['.gitignore', 'Gemfile.lock', '.project', 'LICENSE']
IGNORE_DIRS = ['bin/', 'pkg/']

# Path to a local git repo
repo = Rugged::Repository.new(ARGV[0])

# Get the HEAD commit from master
master_head = repo.branches.find{|br| br.name == "master"}.target

# Walk every commit on master, starting at the last one
Rugged::Walker.walk(repo, show: master_head, sort: Rugged::SORT_DATE) do |commit|
  puts "commit: #{commit.oid}"
  # Count the files
  commit.tree.walk_blobs(:postorder) do |root, entry|
    next if IGNORE_DIRS.include? root
    next if IGNORE_FILES.include? entry[:name]

    file_path = root + entry[:name]
    puts "\tfile: #{file_path}"

    # having been handed a file
    blame = Rugged::Blame.new(repo, file_path, newest_commit: commit)

    # {"julian" => hunk}
    author_hunks = blame.group_by{|hunk| hunk[:final_signature][:name]}

    # Another reduce can be used here
    # Reduce down all lines from this file for this author
    author_to_lines = {}
    author_hunks.each do |author, hunks|
      puts "author: #{author}"
      author_to_lines[author] = hunks.reduce(0) do |memo, hunk|
        puts "hunk: #{hunk}"
        memo += hunk[:lines_in_hunk]
      end
    puts "author_hunks: #{author_hunks}"
    end
  end

end

