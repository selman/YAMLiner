require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Yamliner" do

  before(:all) do
    @test_file = File.join(Dir.pwd, 'spec/test.txt')
    File.open(@test_file, 'w+') do |f|
      f.puts "Test File"
    end
    @input = {:name => 'selman', :surname => 'ulug'}
    YAMLiner::line @input
  end

  it "should raise exception other than Array or Hash" do
    lambda { s=''; YAMLiner::line s}.should raise_exception
  end

  it "should return nil when no file specified to read" do
    @input.yamline_read.should be_nil
  end

  it "should return nil when specified file is not available to read" do
    @input.yamline_settings(:file => 'not_available.txt')
    @input.yamline_read.should be_nil
  end

  it "should read specified file and return nil when no YAMLiner" do
    @input.yamline_settings(:file => @test_file)
    @input.yamline_read.should be_nil
  end

  it 'should write to file' do
    @input.yamline_write!.should_not be_nil
  end

  it "should read file and two objects must be equal" do
    @input.yamline_read.should_not be_nil
    read_lines = @input.yamline_read
    read_lines.each do |rl|
      rl.size.should eql(@input.size)
      @input.each do |k, v|
        rl.has_key?(k).should be_true
        rl.has_value?(v).should be_true
      end
    end
  end

  it 'should delete from file' do
    @input.yamline_delete!.should_not be_nil
    @input.yamline_read.should be_nil
  end

  after(:all) do
    FileUtils.rm(@test_file)
  end
end
