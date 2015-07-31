# encoding: utf-8

require 'bundler'
Bundler.setup

if RUBY_ENGINE == 'rbx'
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'rom-sql'
require 'rom/sql/rake_task'

# FIXME: why do we need to require it manually??
require 'sequel/adapters/postgres'

require 'logger'
begin
  require 'byebug'
rescue LoadError
end

LOGGER = Logger.new(File.open('./log/test.log', 'a'))
DB_URI = 'postgres://localhost/rom'

root = Pathname(__FILE__).dirname
TMP_PATH = root.join('../tmp')

Dir[root.join('shared/*.rb').to_s].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    tmp_test_dir = TMP_PATH.join('test')
    FileUtils.rm_r(tmp_test_dir) if File.exist?(tmp_test_dir)
    FileUtils.mkdir_p(tmp_test_dir)
  end

  config.before do
    @constants = Object.constants
  end

  config.after do
    added_constants = Object.constants - @constants
    added_constants.each { |name| Object.send(:remove_const, name) }
    ROM.instance_variable_set('@gateways', {})
  end
end
