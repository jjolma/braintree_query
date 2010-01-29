require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "braintree_query"
    gem.summary = "Ruby client for accessing Braintree Payment Solution's reporting API"
    gem.description = "Access Braintree Transactions and Customers"
    gem.email = "jeff@animoto.com"
    gem.homepage = "http://github.com/jjolma/braintree_query"
    gem.authors = ["Jeff Jolma"]
    gem.files =  FileList["[A-Z]*", "{bin,generators,lib,test}/**/*", 'lib/jeweler/templates/.gitignore']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_depentrdencies
task :default => :test

begin
  %w{sdoc sdoc-helpers rdiscount}.each { |name| gem name }
  require 'sdoc_helpers'
rescue LoadError => ex
  puts "sdoc support not enabled:"
  puts ex.inspect
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "braintree_query #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
