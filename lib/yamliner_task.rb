class YAMLiner
  require 'rake/tasklib'

  # YAMLiner::Config.new do |c|
  #   c.deneme = "selman"
  # end
  class Tasks < ::Rake::TaskLib
    attr_accessor :params

    def initialize(params = {})
      @params.merge!(params) unless params.empty?
      @yamliner = YAMLiner.new

      yield self if block_given?
      define
    end

    def [](key)
      @params[key]
    end

    def []=(key, value)
      @params[key] = value
    end

    private

    def define
      namespace :ylt do

        desc "Interactive Move"
        task :move do
          @yamliner.ylt_move
        end

        desc "Interactive Copy"
        task :copy do
          @yamliner.ylt_copy
        end

        desc "Interactive File Insert"
        task :insertfile do
          @yamliner.ylt_inserfile
        end

      end
    end

  end #Config

  def ylt_move
    "move"
  end

  def ylt_copy
    "copy"
  end

  def ylt_inserfile
    "insertfile"
  end

end # YAMLiner
