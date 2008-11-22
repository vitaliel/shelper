require 'rake/testtask'

# $: << File.dirname(__FILE__) + "/lib"

task :default => :test

task :test do
  Rake::TestTask.new do |t|
    t.libs << "test" << "lib"
    t.test_files = FileList['test/*test.rb']
    t.verbose = true
  end
end
