require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fakefs_helper')
require 'hastie/report_publisher'

describe Hastie::ReportPublisher do

  def read_file file
    if File.exists? file
      File.open(file, 'r').read
    else
      ""
    end
  end

end

class ReportGeneratorChild < Hastie::ReportGenerator
  no_tasks do
    def config_file
      FakeFsHelper::CONFIG_FILE
    end
  end
end

describe Hastie::ReportPublisher, fakefs: true do
  before :each do
    # tested in server_reader_spec.rb
    FakeFsHelper.stub_config_file
    FakeFsHelper.stub_reports_file
    FakeFsHelper.stub_server_config

    @report_dir = "/tmp/test_report"
    FileUtils.mkdir_p @report_dir
    File.exists?(@report_dir).should == true
  end

  it "should error if input directory is not a report" do
    input = [@report_dir, "--config_file", FakeFsHelper::CONFIG_FILE, "--server_root", FakeFsHelper::SERVER_DIR]

    content = capture(:stdout) do
      lambda { Hastie::ReportPublisher.start input }.should raise_error SystemExit
    end
    content.should match /[Cc]annot .* report.yml/
  end

  it "should error if reports_dir not in server config" do
    FileUtils.touch File.join(@report_dir, "report.yml")
    input = [@report_dir, "--config_file", FakeFsHelper::CONFIG_FILE, "--server_root", FakeFsHelper::SERVER_DIR]

    content = capture(:stdout) do
      lambda { Hastie::ReportPublisher.start input }.should raise_error SystemExit
    end
    content.should match /[Mm]issing reports_dir/
  end

  it "should error if report_file not in local config" do
    FileUtils.touch File.join(@report_dir, "report.yml")
    input = [@report_dir, "--config_file", FakeFsHelper::CONFIG_FILE, "--server_root", FakeFsHelper::SERVER_DIR]

    content = capture(:stdout) do
      lambda { Hastie::ReportPublisher.start input }.should raise_error SystemExit
    end
    content.should match /[Mm]issing report_file/
  end

  it "should error if report_id not in local config" do
    FileUtils.touch File.join(@report_dir, "report.yml")
    input = [@report_dir, "--config_file", FakeFsHelper::CONFIG_FILE, "--server_root", FakeFsHelper::SERVER_DIR]

    content = capture(:stdout) do
      lambda { Hastie::ReportPublisher.start input }.should raise_error SystemExit
    end
    content.should match /[Mm]issing report_id/
  end

  it "should copy report if all required configs are present" do
    report_file = File.join(@report_dir, "report.yml")
    FileUtils.touch report_file
    File.open(report_file, 'w') do |f|
      f.puts "report_id: report"
      f.puts "report_file: report.textile"
    end

    FileUtils.touch File.join(@report_dir, "report.textile")

    FakeFsHelper.add_reports_dir

    input = [@report_dir, "--config_file", FakeFsHelper::CONFIG_FILE,
             "--server_root", FakeFsHelper::SERVER_DIR]

    content = capture(:stdout) do
      lambda { Hastie::ReportPublisher.start input }.should_not raise_error SystemExit
    end

    File.exist?(File.join(FakeFsHelper::SERVER_DIR, "_posts", "report.textile")).should == true
    #content.should match /[Mm]issing reports_dir/
  end
end
