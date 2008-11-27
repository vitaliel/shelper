require 'rake/testtask'

$: << File.expand_path(File.dirname(__FILE__) + '/lib')

task :default => :test
require 'shelper/version'

ENV['EDITOR'] = "nano"
branch = "deb"

task :test do
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/*test.rb']
    t.verbose = true
  end
end

task :tar do
  file = "shelper-" << SHelper::VERSION::STRING << ".tar.gz"
  puts "Creating #{file}"
  sh("git archive --format=tar --prefix='" << File.basename(File.expand_path('.')) << "/' HEAD | gzip -9 > ../" << file)
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
