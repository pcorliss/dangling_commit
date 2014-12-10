#!/usr/bin/env ruby

require 'open3'

# git-create-dangling-commit.rb <SHA> <Tag Name> <SSH Remote>

sha, tag_name, ssh_remote = ARGV

constructed_cmd = "0"*40 + " #{sha} refs/tags/#{tag_name}\0 report-status side-band-64k agent=git/2.0.0"
constructed_cmd = (constructed_cmd.length + 4).to_s(16).rjust(4, '0') + constructed_cmd
constructed_cmd << File.read('empty-pack-file.txt')

hostname, repo = ssh_remote.split(':')
cmd = "ssh -x #{hostname} \"git-receive-pack '#{repo}'\""

Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
  stdin.write constructed_cmd
  $stdout.print stdout.read
  $stderr.print stderr.read
end
