require 'rake/testtask'

task :default => :test

ENV['EDITOR'] = "nano"
branch = "deb"

task :test do
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/*test.rb']
    t.verbose = true
  end
end

task :deb_dch do
  sh "git checkout " << branch
  sh "git rebase work"
  sh "git-dch --debian-branch #{branch} --since=debian/0.1.0-3 --snapshot"
  sh "git commit -a -m snapshot"
end

task :deb => :deb_dch do
  sh "git-buildpackage --git-debian-branch=" << branch
  dir = Dir.pwd
  cd ".."
  sh "export_debs && rsync_debs"
  cd dir
end
