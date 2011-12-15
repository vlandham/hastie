$TESTING=true

require 'simplecov'
SimpleCov.start do
  add_group 'Libraries', 'lib'
  add_group 'Specs', 'spec'
end

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require 'hastie/report_generator'
require 'hastie/report_publisher'

require 'stringio'

require 'rdoc'
require 'rspec'

require 'fakefs/spec_helpers'

ARGV.clear

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true

  config.before :each do
    ARGV.replace []
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def source_root
    File.join(File.dirname(__FILE__), 'fixtures')
  end

  def destination_root
    File.join(File.dirname(__FILE__), 'sandbox')
  end

  alias :silence :capture
end

