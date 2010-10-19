$:.push File.expand_path("../lib", __FILE__)
require "YAMLiner/version"

require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

begin
  require 'flay'
  require 'flay_task'
  FlayTask.new
rescue LoadError
  task :flay do
    abort "Flay is not available. In order to run flay, you must: sudo gem install flay"
  end
end

begin
  require 'flog'
  require 'flog_task'
  FlogTask.new
rescue LoadError
  task :flog do
    abort "Flog is not available. In order to run flog, you must: sudo gem install flog"
  end
end

begin
  require 'reek/rake/task'
  Reek::Rake::Task.new do |t|
    t.fail_on_error = false
    t.verbose = true
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = true
    t.patterns = %w(lib/**/*.rb spec/**/*.rb)
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = YAMLiner::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "YAMLiner #{version}"
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_files.include('lib/**/*.rb')
end
