#Defines YAMLiner class
#require 'yaml'
#require 'fileutils'

module YAMLiner
  def self.line(*objects)
    objects.each do |object|
      
      #YAMLiner class definition
      class << object
        require 'yaml'
        require 'fileutils'

        attr_accessor_with_default_setter :params do
          { :name => 'YAMLiner',
            :file => '',
            :line => 0,
            :prefix => '#',
            :postfix => '',
            :backup => false } 
        end

        attr_accessor_with_default_setter :file do
          []
        end

        def match_line
          %r/(^#{Regexp.escape(@params[:prefix] + @params[:name])})(.*?)(#{Regexp.escape(@params[:postfix])}$)/
        end

        #Reads your supplied file/files if successfull returns readed object 
        #  Dir['**/*.txt].each {|f| y.read }
        def yamline_read
          return unless read_file?
          @file.each do |rline|
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
#          return if @file.size < params[:line]
          temp = []
          @file.each do |wline|
            if @params[:line] == @file.index(wline)
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
          @file.each do |dline|
            temp << dline unless dline =~ match_line
          end
          save_file(temp)
        end

        #Returns generated YAMLiner line
        def yamline
          #You can get inline YAML only redefining *to_yaml_style* method
          instance_eval { def to_yaml_style; :inline; end }
          @params[:prefix] + @params[:name] + self.to_yaml.chop + @params[:postfix] + "\n"
        end

        private

        def read_file?
          return if @params[:file].empty?
          return unless File.exists?(@params[:file])
          @file = File.readlines(@params[:file])
        end

        def save_file(temp)
          @params[:backup] ? file = "#{@params[:file]}.bak" : file = @params[:file]
          File.open(file, 'w+') { |f| f.puts temp }
          read_file?
        end

      end # YAMLiner

    end
  end
end

class Module
  def attr_accessor_with_default_setter( *syms, &block )
    raise 'Default value in block required' unless block
    syms.each do | sym |
      module_eval do
        attr_writer( sym )
        define_method( sym ) do | |
          class << self; self; end.class_eval do
            attr_reader( sym )
          end
          if instance_variables.include? "@#{sym}"
            instance_variable_get( "@#{sym}" )
          else
            instance_variable_set( "@#{sym}", block.call )
          end
        end
      end
    end
    nil
  end
end
