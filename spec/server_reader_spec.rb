require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fakefs_helper')
require 'hastie/server_reader'
require 'hastie/constants'

class ServerReaderChild < Hastie::ServerReader
  no_tasks do
    def config_file
      FakeFsHelper::CONFIG_FILE
    end
  end

  def output_options
    options
  end
end

describe Hastie::ReportGenerator, fakefs: true do

  describe "missing config file" do
    it "should report missing config file and exit" do
      content = capture(:stdout) do
        lambda { ServerReaderChild.start }.should raise_error SystemExit
      end
      content.should match /[Nn]o config file found/
    end
  end

  describe "missing server dir" do
    before :each do
      FakeFsHelper.stub_config_file
    end

    it "should report missing server dir and exit" do
      File.exists?(FakeFsHelper::CONFIG_FILE).should == true
      content = capture(:stdout) do
        lambda { ServerReaderChild.start }.should raise_error SystemExit
      end
      content.should match /[Cc]annot find server/
    end
  end

  describe "valid server dir" do
    before :each do
      FakeFsHelper.stub_config_file
      FakeFsHelper.stub_server_dir
      File.directory?(FakeFsHelper::SERVER_DIR).should == true
    end

    it "should report missing server config and exit" do
      content = capture(:stdout) do
        lambda { ServerReaderChild.start }.should raise_error SystemExit
      end
      content.should match /[Cc]annot find #{Hastie::SERVER_CONFIG_FILE} file in server/
    end

    it "should report missing reports.yml file and exit" do
      FakeFsHelper.stub_server_config
      content = capture(:stdout) do
        lambda { ServerReaderChild.start }.should raise_error SystemExit
      end
      content.should match /[Cc]annot find #{Hastie::SERVER_REPORTS_FILE} file/
    end

    it "should report options when all required files are present" do
      FakeFsHelper.stub_server_config
      FakeFsHelper.stub_reports_file
      lambda { ServerReaderChild.start }.should_not raise_error SystemExit
      output = ServerReaderChild.start
      last_output = output[-1]
      last_output["server_root"].should == FakeFsHelper::SERVER_DIR
    end

  end
  it "should take server_root as input parameter" do
    FakeFsHelper.stub_config_file
    new_dir = "/another/path/to/server"

    FakeFsHelper.stub_server_dir new_dir
    FakeFsHelper.stub_server_config new_dir
    FakeFsHelper.stub_reports_file new_dir
    input = ["--server_root", new_dir]
    output = ServerReaderChild.start input
    last_output = output[-1]
    last_output["server_root"].should == new_dir
  end
end
