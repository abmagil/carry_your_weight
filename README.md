# Carry Your Weight

You know that dev who's never actually writes any code?  The one who's always going on an on about "terseness" and "good design" and "not littering your codebase with needless boilerplate"? Don't you hate them? Don't you hate how they constantly replace your 14 classes with a single, well-documented, robust one? Well you'll need a tool to prove how little they contribute, and _Carry Your Weight_ is that tool!

## What Is It

_Carry Your Weight_ is a quaint little webservice to crawl, blame, and graph, ownership of your entire codebase. Every file, every line, _Carry Your Weight_ will tell you how much each contributer...contributed....

## How It Works
Simply enter a GitHub repo name and _Carry Your Weight_ will go get that repo and begin to crawl through its commits, going back to its very beginnings. At each commit, every line will be `git blame`'d and we'll begin to accumulate statistics for each contributer. As each commit is finished parsing, we'll send that information up to your browser and graph out ownership at that commit.

_Carry Your Weight_ will continue this process until the entire repo (or at least the default branch of it) is parsed, giving you the information you need to prove that you, alone, are the most important developer!

# Dev Setup

_Carry Your Weight_ is a pretty standard rails application, with a few minor exceptions.

1. We use [rugged](https://github.com/libgit2/rugged) for parsing git repos. Installation of Rugged requires CMake, so be sure to have that (on Mac- `brew install cmake`) before attempting to bundle. Details can be found on Rugged's github page.
1. We use MongoDB for a backing data store, to cache previously parsed commits. This must be installed prior to initial run.

Otherwise, the standard Rails conventions apply-

1. `git clone git@github.com:abmagil/carry_your_weight.git`
1. `bundle install`
1. `rails db:setup`
1. `rails s`
1. Browse to localhost:3000
