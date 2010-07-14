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
      if object.respond_to?(:to_yaml)
        object.extend(YAMLinerActions)
        object.instance_variable_set(:@lines, [])
        object.instance_variable_set(:@params, params)
      else
        raise "#{object.class} not responds \"to_yaml\" method"
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

    def match_line
      %r/(^#{Regexp.escape(@params[:prefix] + @params[:name])})(.*?)(#{Regexp.escape(@params[:postfix])}$)/
    end

    #Reads your supplied file/files if successfull returns readed object 
    #  Dir['**/*.txt].each {|f| y.read }
    def yamline_read
      return unless read_file?
      @lines.each do |rline|
        if rline =~ match_line
          return YAML::load($2)
        end
      end
      nil
    end

    #Writes the generated YAMLiner line to supplied file/files if there
    #is a same formated line it writes over it
    def yamline_write!
      read_file?
      #          return if @lines.size < params[:line]
      temp = []
      @lines.each do |wline|
        if @params[:line] == @lines.index(wline)
          wline =~ match_line ? wline = yamline : temp << yamline
        end
        temp << wline
      end
      save_file(temp)
    end

    #Finds and deletes formatted line from supplied file/files
    def yamline_delete!
      return unless read_file?
      temp = []
      @lines.each do |dline|
        temp << dline unless dline =~ match_line
      end
      save_file(temp)
    end

    #Returns generated YAMLiner line
    def yamline
      @params[:prefix] + @params[:name] + self.to_yaml.chop + @params[:postfix] + "\n"
    end

    private

    def read_file?
      return if @params[:file].empty?
      return unless File.exists?(@params[:file])
      @lines = File.readlines(@params[:file])
    end

    def save_file(temp)
      @params[:writeto].empty? ? tofile = @params[:file] : tofile = @params[:writeto]
      File.open(tofile, 'w+') { |file| file.puts temp }
      read_file?
    end

  end # YAMLinerActions

end # YAMLiner
