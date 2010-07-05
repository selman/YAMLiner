begin
  require File.join(Dir.pwd, 'lib/yamliner')
  require File.join(Dir.pwd, 'lib/yamliner_task')
  YAMLiner::Tasks.new
rescue LoadError => e
  puts e.message
  puts "YAMLiner not available. Install it with: gem install YAMLiner"
end
