begin
  require File.join(File.dirname(__FILE__), '../lib/yamliner_task')
  YAMLiner::Tasks.new do |c|
    c.params[:name] = "selman"
  end
rescue LoadError
  puts "YAMLiner not available. Install it with: gem install YAMLiner"
end
