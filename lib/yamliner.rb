#Defines YAMLiner class
require 'yaml'
require 'fileutils'


#YAMLiner class definition
class YAMLiner
  #Our accessor to carry values between function [] and []= redifined
  #you can access all params like this:
  #  y = YAMLiner.new()
  #  y[:name] = "my_comment"
  attr_accessor :params

  #Our initializer
  def initialize(params = {})
    @params = {
      :name => 'YAMLiner',
      :file => '',
      :line => 0,
      :object => nil,
      :prefix => '#',
      :postfix => '',
      :backup => false
    }
    @params.merge!(params) unless params.empty?
    @file = []
    check_params
    @match_line = %r/(^#{Regexp.escape(@params[:prefix] + @params[:name])})(.*?)(#{Regexp.escape(@params[:postfix])}$)/
  end

  #Reads your supplied file/files if successfull returns readed object 
  #  Dir['**/*.txt].each {|f| y.read }
  def read
    check_params [:file]
    return false if @file.empty?
    @file.each do |rline|
      if rline =~ @match_line
        return YAML::load($2)
      end
    end
    return false
  end

  #Writes the generated YAMLiner line to supplied file/files if there
  #is a same formated line it writes over it
  def write!
    check_params [:file, :object]
    return false if @file.size < params[:line]
    temp = []
    @file.each do |wline|
      if @params[:line] == @file.index(wline)
        wline =~ @match_line ? wline = yamline : temp << yamline
      end
      temp << wline
    end
    save_file(temp)
  end

  #Finds and deletes formatted line from supplied file/files
  def delete!
    check_params [:file]
    return false if @file.empty?
    temp = []
    @file.each do |dline|
      temp << dline unless dline =~ @match_line
    end
    save_file(temp)
  end

  #Returns generated YAMLiner line
  def yamline
    #You can get inline YAML only redefining *to_yaml_style* method
    @params[:object].instance_eval { def to_yaml_style; :inline; end }
    @params[:prefix] + @params[:name] + @params[:object].to_yaml.chop + @params[:postfix] + "\n"
  end

  #Shortcut to read params
  def [](key)
    @params[key]
  end

  #Shortcut to write params
  def []=(key, value)
    @params[key] = value
  end

  private

  def read_file?
    return false if @params[:file].empty?
    return false unless File.exists?(@params[:file])
    @file = File.readlines(@params[:file])
  end

  def save_file(temp)
    @params[:backup] ? file = "#{@params[:file]}.bak" : file = @params[:file]
    File.open(file, 'w+') { |f| f.puts temp }
    read_file?
  end

  def check_params(params = [])
    params += [:name, :prefix]
    params.each do |opt|
      raise ArgumentError.new("\":#{opt}\" option must be set") if @params[opt].nil? or @params[opt].empty?
    end
    read_file? if params.include?(:file)
  end

end # YAMLiner

