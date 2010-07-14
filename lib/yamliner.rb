require 'yaml'
require 'fileutils'

#Defines YAMLiner Module
module YAMLiner
  extend self

  def line(*objects)
    params =
      {:name => 'YAMLiner',
      :file => '',
      :line => 0,
      :prefix => '#',
      :postfix => '',
      :writeto => '' }

    objects.each do |object|
      if object.kind_of?(Array) or object.kind_of?(Hash)
        object.extend(YAMLinerActions)
        object.instance_variable_set(:@params, params)
      else
        raise "#{object.class} not suitable for data containing use Hash or Array"
      end
    end
  end

  #CRUD operations functions and some tools
  module YAMLinerActions
    attr_accessor :params

    #You can get inline YAML only redefining this method
    def to_yaml_style
      :inline
    end

    #Reads your supplied file/files if successfull returns readed object 
    #  Dir['**/*.txt].each {|f| y.read }
    def yamline_read(loaded = true)
      return unless lines = read_file?
      match_line = %r/(^#{Regexp.escape(@params[:prefix] + @params[:name])})(.*?)(#{Regexp.escape(@params[:postfix])}$)/
      line_l = []
      line_s = lines.select {|s| s =~ match_line; line_l << YAML::load($2) if $2 }
      return if line_s.empty?
      loaded ? line_l : line_s
    end

    #Writes the generated YAMLiner line to supplied file/files if there
    #is a same formated line it writes over it
    def yamline_write!
      unless lines = read_file?
        lines += yamline
      else
        lines.insert(params[:line], yamline)
      end
      save_file(lines)
    end

    #Finds and deletes formatted line/lines from supplied file/files
    def yamline_delete!
      return unless lines = read_file?
      lines_readed = self.yamline_read(false)
      lines_readed.each {|lr| lines.delete(lr) } if lines_readed
      save_file(lines)
    end

    #Returns generated YAMLiner line
    def yamline
      @params[:prefix] + @params[:name] + self.to_yaml.chop + @params[:postfix] + "\n"
    end

    private

    def read_file?
      return if @params[:file].empty?
      return unless File.exists?(@params[:file])
      File.readlines(@params[:file])
    end

    def save_file(temp)
      @params[:writeto].empty? ? tofile = @params[:file] : tofile = @params[:writeto]
      File.open(tofile, 'w+') { |file| file.puts temp }
      read_file?
    end

  end # YAMLinerActions

end # YAMLiner
