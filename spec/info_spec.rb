require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fakefs_helper')
require 'hastie/info'


describe Hastie::Info do

  before :each do
    @input = []
    # @config_file = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "hastie_config"))
    # @server_dir = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "server"))
    # @output_dir = File.expand_path(File.join(File.dirname(__FILE__), "sandbox"))
    # @date = "2011-11-31"
  end

  after :each do
    # FileUtils.rm_r @output_dir if File.exists?(@output_dir)
  end

  it "should work" do
    content = capture(:stdout) do
      # lambda { Hastie::Info.start @input }.should_not raise_error SystemExit
    end
      Hastie::Info.start @input
  end

end

