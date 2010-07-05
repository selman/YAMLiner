require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Yamliner" do

  before(:all) do
    @test_file = Tempfile.new('testing')
    @test_file.puts "Test File"
    @input = {:name => 'selman', :surname => 'ulug'}
    @yamliner = YAMLiner.new(:file => @test_file.path, :input => @input)
  end

  it "should raise ArgumentError without :name or :prefix parameters" do
    lambda { YAMLiner.new :name => '' }.should raise_exception(ArgumentError)
    lambda { YAMLiner.new :prefix => nil }.should raise_exception(ArgumentError)
    lambda { YAMLiner.new }.should_not raise_exception(ArgumentError)
  end

  after(:all) do
    @test_file.close
  end
end
