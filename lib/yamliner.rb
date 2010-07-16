#= YAMLiner
#Simple library for CRUD operations on formatted comment lines with
#<b>inline YAML</b>.
#  a = {:name => 'selman', :surname => 'ulug'}
#  YAMLiner::line a
#  a.yamline_settings(:name => 'MyLine')
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
      if object.kind_of?(Array) or object.kind_of?(Hash)
        object.extend(YAMLinerActions)
        object.instance_variable_set(:@settings, settings)
      else
        raise "only Hash or Array classes supported: #{object.class} not supported"
      end
    end
  end

  #CRUD operation functions and some tools
  module YAMLinerActions
    attr_reader :settings

    #You can get inline YAML only redefining this method
    def to_yaml_style
      :inline
    end

    #Returns generated YAMLiner line
    #  >> a.yamline
    #  => "#YAMLiner--- {:name: selman, :surname: ulug}\n"
    def yamline
      @settings[:prefix] + @settings[:name] + self.to_yaml.chop + @settings[:postfix] + "\n"
    end

    #YAMLiner settings default values
    #  :name => 'YAMLiner'
    #  :files => []
    #  :line => 0
    #  :prefix => '#'
    #  :postfix => ''
    #  :writeto => ''
    def yamline_settings(sets = {})
      @settings.merge!(sets) unless sets.empty?
    end

    #Reads your supplied file/files if successfull returns readed object 
    #  Dir['**/*.txt'].each {|f| a.yamline_settins(:file => f); a.yamline_read } 
    def yamline_read(lines = nil, loaded = true)
      lines = file_lines unless lines
      return unless lines
      matcher = %r{(^#{Regexp.escape(@settings[:prefix] + @settings[:name])})(.*?)(#{Regexp.escape(@settings[:postfix])}$)}
      line_l = []
      line_s = lines.select {|line| line =~ matcher; line_l << YAML::load($2) if $2 }
      return if line_s.empty?
      loaded ? line_l : line_s
    end

    #Writes the generated YAMLiner line to supplied file/files if there
    #is a same formated line it deletes and write again.
    #  a.yamline_settings(:file => 'test.txt')
    #  a.yamline_write!
    def yamline_write!
      lines = file_lines || []
      yamline_delete!(lines) unless lines.empty?
      lines.insert(settings[:line], yamline)
      save_file(lines)
    end

    #Finds and deletes formatted line/lines from supplied
    #file/files. if formetted line is not uniq it deletes all of them.
    #  a.yamline_settings(:file => 'test.txt')
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
      file = @settings[:file]
      return if file.empty?
      return unless File.exists?(file)
      File.readlines(file)
    end

    def save_file(temp)
      writeto = @settings[:writeto]
      writeto = @settings[:file] if writeto.empty?
      File.open(writeto, 'w+') { |file| file.puts temp }
      true
    end

  end # YAMLinerActions

end # YAMLiner
