require 'yaml'
require 'tempfile'
require 'fileutils'

#You can get inline YAML only redefining "to_yaml_style"
class Object
  def to_yaml_style
    :inline
  end
end

=begin
  y = YAMLiner.new("test.rb", :line => 2, :object => {:name => "selman"})
=end
class YAMLiner
  attr_accessor :file, :options

  def initialize(file, options = {})
    @options = {
      :name => 'YAMLiner',
      :line => 1,
      :object => nil,
      :beginner => '#',
      :ender => '',
      :backup => true
    }
    @options.merge!(options) unless options.empty?
    @file = file
  end

  def read
    File.foreach(@file) do |line|
      if line =~ match_line_format
        @options[:object] = object_from(line)
        @options[:line] = $.
        break
      end
    end
    @options[:object]
  end

  def write!
    generated = generate_line
    with_temp do |temp|
      File.foreach(@file) do |line|
        if @options[:line] == $.
          line =~ match_line_format ? line = generated : temp << generated
        end
        temp << line
      end
    end
  end

  def delete!
    with_temp do |temp|
      File.foreach(@file) do |line|
        temp << line unless line =~ match_line_format
      end
    end
  end

  private

  def with_temp
    temp = Tempfile.new('working')
    yield(temp)
  ensure
    temp.close
    FileUtils.mv(@file, "#{@file}.bak") if @options[:backup]
    FileUtils.mv(temp.path, @file)
  end

  def generate_line
    @options[:beginner] + @options[:name] + @options[:object].to_yaml.chop + @options[:ender] + "\n"
  end

  def match_line_format
    %r(^#{Regexp.escape(@options[:beginner] + @options[:name])}.*#{Regexp.escape(@options[:ender])}$)
  end

  def object_from(line)
    line.gsub!(%r(^#{Regexp.escape(@options[:beginner] + @options[:name])}), '')
    line.gsub!(%r(#{Regexp.escape(@options[:ender])}$), '') unless @options[:ender].empty?
    YAML::load(line)
  end

end
