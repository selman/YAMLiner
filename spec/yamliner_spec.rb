require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Yamliner" do

  before(:all) do
    @test_file = File.join(Dir.pwd, 'spec/test.txt')
    @test_file_bak = File.join(Dir.pwd, 'spec/test.txt.bak')
    File.open(@test_file, 'w+') do |f|
      f.puts "Test File"
    end
    @input = {:name => 'selman', :surname => 'ulug'}
    @y = YAMLiner.new(:file => @test_file, :object => @input)
  end

  it "should raise ArgumentError without :name or :prefix parameters" do
    lambda { YAMLiner.new :name => '' }.should raise_exception(ArgumentError)
    lambda { YAMLiner.new :prefix => nil }.should raise_exception(ArgumentError)
    lambda { YAMLiner.new }.should_not raise_exception(ArgumentError)
  end

  it 'should write to file and read from file' do
    @y.write!
    @y[:file] = @test_file_bak
    should be_true(@y[:object] == @input)
    @y[:file] = @test_file
  end

  it 'should delete from file' do
    @y.delete!
    @y[:file] = @test_file_bak
    should be_true(@y.read == @input)
    @y[:file] = @test_file
  end

  after(:all) do
    FileUtils.rm(@test_file)
    FileUtils.rm(@test_file_bak)
  end
end
