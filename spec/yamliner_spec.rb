require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Yamliner" do

  before(:all) do
    @test_file = File.join(Dir.pwd, 'spec/test.txt')
    File.open(@test_file, 'w+') do |f|
      f.puts "Test File"
    end
    @input = {:name => 'selman', :surname => 'ulug'}
    @y = YAMLiner.new(:object => @input)
  end

  it "should raise ArgumentError without :name or :prefix parameters" do
    lambda { YAMLiner.new :name => '' }.should raise_exception(ArgumentError)
    lambda { YAMLiner.new :prefix => nil }.should raise_exception(ArgumentError)
    lambda { YAMLiner.new }.should_not raise_exception(ArgumentError)
  end

  it "should raise Argument error when no file specified to read" do
    lambda { @y.read }.should raise_exception(ArgumentError)
  end

  it "should return false when specified file is not available to read" do
    @y[:file] = 'not_available.txt'
    @y.read.should be_false
  end

  it "should read specified file and return false when no YAMLiner" do
    @y[:file] = @test_file
    @y.read.should be_false
  end

  it 'should write to file' do
    @y.write!.should be_true
  end

  it "should read file and two objects must be equal" do
    @y.read.should_not be_false
    @y[:object].size.should eql(@input.size)
    @input.each do |k, v|
      @y[:object].has_key?(k).should be_true
      @y[:object].has_value?(v).should be_true
    end
  end

  it 'should delete from file' do
    @y.delete!.should be_true
    @y.read.should be_false
  end

  after(:all) do
    FileUtils.rm(@test_file)
  end
end
