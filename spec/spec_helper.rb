$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'yamliner'
require 'spec'
require 'spec/autorun'
require 'fileutils'
require 'rake'

Spec::Runner.configure do |config|

end
