require 'fileutils'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fakefs_helper')
require 'hastie/report_watcher'

describe Hastie::ReportWatcher do

  def read_file file
    if File.exists? file
      File.open(file, 'r').read
    else
      ""
    end
  end

  before :each do
    @config_file = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "hastie_config"))
    @config_ru_file = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "config.ru"))
    @org_server_dir = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "server"))
    @org_report_dir = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "report"))

    @sandbox = File.expand_path(File.join(File.dirname(__FILE__), "sandbox"))

    @report_dir = File.join(@sandbox, "report")

    FileUtils.mkdir_p @sandbox

    FileUtils.cp_r @org_report_dir, @report_dir

    @report_name = File.basename(Dir.glob(File.join(@report_dir, "*.textile"))[0])

    @input = [@report_dir]

  end

  after :each do
    FileUtils.rm_r @sandbox if File.exists?(@sandbox)
  end

  it "should not error if in a report dir" do
    content = ""
    pid = fork do
      content = capture(:stderr) do
        lambda { Hastie::ReportWatcher.start @input }.should_not raise_error SystemExit
      end
    end

    sleep 5

    Process.kill 'INT', pid
    Process.wait pid
    puts content
  end

  it "should raise errror if not in a report dir" do
    input = [@sandbox]
    content = capture(:stdout) do
      lambda { Hastie::ReportWatcher.start input }.should raise_error SystemExit
    end
  end

  it "should start sinatra if config.ru file is present" do
    FileUtils.cp_r @config_ru_file, @report_dir

    # Hastie::ReportWatcher.start @input

    content = ""
    pid = fork do
      content = capture(:stderr) do
        lambda { Hastie::ReportWatcher.start @input }#.should_not raise_error SystemExit
      end
    end

    sleep 5

    Process.kill 'INT', pid
    Process.wait pid
    puts "SINATRA:"
    puts content
  end

end

describe Hastie::ReportWatcher, fakefs: true do
  before :each do
    # tested in server_reader_spec.rb
    FakeFsHelper.stub_config_file
    FakeFsHelper.stub_reports_file
    FakeFsHelper.stub_server_config

    @report_dir = "/tmp/test_report"
    FileUtils.mkdir_p @report_dir
    File.exists?(@report_dir).should == true
  end

  it "should be happy" do

  end
end
