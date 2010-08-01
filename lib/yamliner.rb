#= YAMLiner
#Simple library for CRUD operations on formatted comment lines with
#<b>inline YAML</b>.
#  a = {:name => 'selman', :surname => 'ulug'}
#  YAMLiner::line a
#  a.yamline_set(:name => 'MyLine')
require 'yaml'
require 'fileutils'

#YAMLiner module definition
module YAMLiner
  extend self

  #extends given Array or Hash instance with YAMLinerActions
  #  a = {:name => 'selman', :surname => 'ulug'}
  #  YAMLiner::line a
  def line(*objects)
    settings =
      {:name => 'YAMLiner',
      :file => '',
      :line => 0,
      :prefix => '#',
      :postfix => '',
      :writeto => '' }

    objects.each do |object|
      if object.respond_to?(:to_yaml)
        object.extend(YAMLinerActions)
        object.instance_variable_set(:@yamline_settings, settings)
      else
        raise "#{object.class} do not responding to to_yaml method"
      end
    end
  end

  #CRUD operation functions and some tools
  module YAMLinerActions
    attr_reader :yamline_settings

    #You can get inline YAML only redefining this method
    def to_yaml_style
      :inline
    end

    #aliasing to_yaml_properties to remove our instance variable
    alias to_yaml_properties_orginal to_yaml_properties

    #removing our yamline_settings instance variable
    def to_yaml_properties
      to_yaml_properties_orginal - [:@yamline_settings]
    end

    #Returns generated YAMLiner line
    #  >> a.yamline
    #  => "#YAMLiner--- {:name: selman, :surname: ulug}\n"
    def yamline
      @yamline_settings[:prefix] + @yamline_settings[:name] + to_yaml.chop + @yamline_settings[:postfix] + "\n"
    end

    #YAMLiner settings default values
    #  :name => 'YAMLiner'
    #  :files => []
    #  :line => 0
    #  :prefix => '#'
    #  :postfix => ''
    #  :writeto => ''
    def yamline_set(settings = {})
      @yamline_settings.merge!(settings) unless settings.empty?
    end

    #Reads your supplied file/files if successfull returns readed object 
    #  Dir['**/*.txt'].each {|f| a.yamline_set(:file => f); a.yamline_read } 
    def yamline_read(lines = nil, loaded = true)
      lines = file_lines unless lines
      return unless lines
      matcher = %r{(^#{Regexp.escape(@yamline_settings[:prefix] + @yamline_settings[:name])})(.*?)(#{Regexp.escape(@yamline_settings[:postfix])}$)}
      line_l = []
      line_s = lines.select {|line| line =~ matcher; line_l << YAML::load($2) if $2 }
      return if line_s.empty?
      loaded ? line_l : line_s
    end

    #Writes the generated YAMLiner line to supplied file/files if there
    #is a same formated line it deletes and write again.
    #  a.yamline_set(:file => 'test.txt')
    #  a.yamline_write!
    def yamline_write!
      lines = file_lines || []
      yamline_delete!(lines) unless lines.empty?
      lines.insert(@yamline_settings[:line], yamline)
      save_file(lines)
    end

    #Finds and deletes formatted line/lines from supplied
    #file/files. if formetted line is not uniq it deletes all of them.
    #  a.yamline_set(:file => 'test.txt')
    #  a.yamline_delete!
    def yamline_delete!(lines = nil)
      lines = file_lines unless lines
      return unless lines
      lines_readed = yamline_read(lines, false)
      lines_readed.each {|lr| lines.delete(lr) } if lines_readed
      save_file(lines)
    end

    private

    def file_lines
      file = @yamline_settings[:file]
      return if file.empty?
      return unless File.exists?(file)
      File.readlines(file)
    end

    def save_file(temp)
      writeto = @yamline_settings[:writeto]
      writeto = @yamline_settings[:file] if writeto.empty?
      File.open(writeto, 'w+') { |file| file.puts temp }
      true
    end

  end # YAMLinerActions

end # YAMLiner
