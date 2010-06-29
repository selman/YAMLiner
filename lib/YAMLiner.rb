require 'yaml'
require 'tempfile'
require 'fileutils'

class Object
  def to_yaml_style
    :inline
  end
end

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
    with_temp do |t|
      File.foreach(@file) do |line|
        if @options[:line] == $.
          line =~ match_line_format ? line = generate_line : t << generate_line
        end
        t << line
      end
    end
  end

  def delete!
    with_temp do |t|
      File.foreach(@file) do |line|
        t << line unless line =~ match_line_format
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
