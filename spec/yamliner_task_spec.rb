require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "YamlinerTask" do

  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    load File.join(Dir.pwd, 'spec/test.rake')
#    Rake::Task.define_task(:config)
  end

  it 'should run rake ylt:move' do
    @rake["ylt:move"].invoke
  end

  it 'should run rake ylt:copy' do
    @rake["ylt:copy"].invoke
  end

  it 'should run rake ylt:insertfile' do
    @rake["ylt:insertfile"].invoke
  end

  after(:each) do
    Rake.application = nil
  end
end
