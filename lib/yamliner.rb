=begin
  y = YAMLiner.new(:file => "test.rb", :line => 2, :object => {:name => "selman"})
=end
class YAMLiner
  require 'yaml'
  require 'tempfile'
  require 'fileutils'

  attr_accessor :params

  def initialize(params = {})
    @params = {
      :name => 'YAMLiner',
      :file => nil,
      :line => 1,
      :object => nil,
      :yaml => nil,
      :prefix => '#',
      :postfix => '',
      :backup => true
    }
    @params.merge!(params) unless params.empty?
    check_params
    @match_line = %r/(^#{Regexp.escape(@params[:prefix] + @params[:name])})(.*?)(#{Regexp.escape(@params[:postfix])}$)/
    @file = [] || File.readlines(params[:file])
  end

  def read
    return false if @file.empty?
    check_params [:file]
    @file.each do |rline|
      if rline =~ @match_line
        @params[:yaml] = $2 + '\n'
        @params[:object] = YAML::load($2)
        @params[:line] = $.
        break
      end
    end
    @params[:object]
  end

  def write!
    check_params [:file, :object]
    yline = yamline
    temp = []
    @file.each do |wline|
      if @params[:line] == $.
        wline =~ @match_line ? wline = yline : temp << yline
      end
      temp << wline
    end
    save_file(temp)
  end

  def delete!
    return false if @file.empty?
    check_params [:file]
    temp = []
    @file.each do |dline|
      temp << dline unless dline =~ @match_line
    end
    @params[:object] = nil
    save_file(temp)
  end

  def yamline
    @params[:prefix] + @params[:name] + @params[:object].to_yaml.chop + @params[:postfix] + "\n"
  end

  def [](key)
    @params[key]
  end

  def []=(key, value)
    @params[key] = value
  end

  private

  def save_file(temp)
    @params[:backup] ? file = "#{params[:file]}.bak" : file = params[:file]
    File.open(file, 'w+') { |f| f.puts temp }
    @file = File.readlines(params[:file])
    return true
  end

  def check_params(params = [])
    params += [:name, :prefix]
    params.each do |opt|
      raise ArgumentError.new("\":#{opt}\" option must be set") if @params[opt].nil? or @params[opt].empty?
    end
  end

end

#You can get inline YAML only redefining "to_yaml_style"
class Object
  def to_yaml_style
    :inline
  end
end # Object
