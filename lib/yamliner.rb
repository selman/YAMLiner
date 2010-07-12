#= What is this?
#With this library you gives a ruby object and it returns this to
#<b>inline YAML</b> line with your specified options.
#== Installation
#  (sudo) gem install YAMLiner
#then in your source code;
#  require 'yamliner'
require 'yaml'
require 'fileutils'

#= Usage Samples
#  >> my_hash = {:name => 'selman', :surname => 'ulug'}
#  => {:name=>"selman", :surname=>"ulug"}
#  >> y = YAMLiner.new(:object => my_hash)
#  => #<YAMLiner:0x9a19d00 @params={:name=>"YAMLiner", :file=>"", :line=>0, :object=>{:name=>"selman", :surname=>"ulug"}, :prefix=>"#", :postfix=>"", :backup=>true}, file[], match_line>                                          
#  >> y.yamline 
#  => "#YAMLiner--- {:name: selman, :surname: ulug}\n"
#It supplies
#CRUD[http://en.wikipedia.org/wiki/Create,_read,_update_and_delete]
#operation functions #read, #delete!, #write! (creates and updates)
#you can change :name, :prefix, :postfix for every type of text file
#comment styles like this:
#  >> y[:prefix] = '/*'
#  => "/*"
#  >> y[:postfix] = '*/'
#  => "*/"
#  >> y[:name] = 'my_c_comment'
#  => "my_c_comment"
#  >> y.yamline 
#  => "/*my_c_comment--- {:name: selman, :surname: ulug}*/\n"
class YAMLiner
  #Redifined [] and []= you can access all parameters like:
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
      :backup => true
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

  def read_file
    unless @params[:file].empty?
      begin
        @file = File.readlines(@params[:file])
      rescue Errno::ENOENT
        #file not found it's ok for writing
      end
    end
  end

  def save_file(temp)
    @params[:backup] ? file = "#{@params[:file]}.bak" : file = @params[:file]
    File.open(file, 'w+') { |f| f.puts temp }
    read_file
  end

  def check_params(params = [])
    params += [:name, :prefix]
    params.each do |opt|
      raise ArgumentError.new("\":#{opt}\" option must be set") if @params[opt].nil? or @params[opt].empty?
    end
    read_file
  end

end # YAMLiner

class Object
  #You can get inline YAML only redefining this method
  def to_yaml_style
    :inline
  end
end # Object
