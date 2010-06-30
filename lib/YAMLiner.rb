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
  y = YAMLiner.new(:file => "test.rb", :line => 2, :input => {:name => "selman"})
=end
class YAMLiner

  def initialize(options = {})
    @options = {
      :name => 'YAMLiner',
      :file => '',
      :line => 1,
      :input => nil,
      :output => nil,
      :prefix => '#',
      :postfix => '',
      :backup => true
    }
    @options.merge!(options) unless options.empty?
    check_options
    @match_line = %r/(^#{Regexp.escape(@options[:prefix] + @options[:name])})(.*?)(#{Regexp.escape(@options[:postfix])}$)/
  end

  def read
    check_options [:file]
    File.foreach(@options[:file]) do |rline|
      if rline =~ @match_line
        @options[:output] = YAML::load($2)
        @options[:line] = $.
        break
      end
    end
    @options[:output]
  end

  def write!
    check_options [:file, :line, :input]
    yamline = @options[:prefix] + @options[:name] + @options[:input].to_yaml.chop + @options[:postfix] + "\n"

    with_temp do |temp|
      File.foreach(@options[:file]) do |wline|
        if @options[:line] == $.
          wline =~ @match_line ? wline = yamline : temp << yamline
        end
        temp << wline
      end
    end
  end

  def delete!
    check_options [:file]
    with_temp do |temp|
      File.foreach(@options[:file]) do |dline|
        temp << dline unless dline =~ @match_line
      end
    end
  end

  private

  def with_temp
    temp = Tempfile.new('working')
    yield(temp)
  ensure
    temp.close
    file = @options[:file]
    FileUtils.mv(file, "#{file}.bak") if @options[:backup]
    FileUtils.mv(temp.path, file)
  end

  def check_options(options)
    options += [:name, :prefix]
    options.each do |opt|
      raise ArgumentError.new("\":#{opt}\" option must be set") if @options[opt].nil? or @options[opt].empty?
    end
  end

end
