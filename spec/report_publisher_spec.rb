require 'grit'
require 'fileutils'
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

  before :each do
    @config_file = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "hastie_config"))
    @org_server_dir = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "server"))
    @org_report_dir = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "report"))

    @sandbox = File.expand_path(File.join(File.dirname(__FILE__), "sandbox"))

    @server_dir = File.join(@sandbox, "server")
    @report_dir = File.join(@sandbox, "report")

    FileUtils.mkdir_p @sandbox

    FileUtils.cp_r @org_server_dir, @server_dir
    FileUtils.cp_r @org_report_dir, @report_dir

    @report_name = File.basename(Dir.glob(File.join(@report_dir, "*.textile"))[0])
    # FileUtils.cd(@server_dir) do
    #   system("git init .")
    #   system("git add .")
    #   system("git commit -m \\"initial commit\\"")
    #   system("git branch server")
    #   system("git checkout server")
    # end

    @input = [@report_dir, "--config_file", @config_file, "--server_root", @server_dir]
  end

  after :each do
    FileUtils.rm_r @sandbox if File.exists?(@sandbox)
  end

  it "should copy new report into reports_dir" do
    content = capture(:stdout) do
      lambda { Hastie::ReportPublisher.start @input }.should_not raise_error SystemExit
    end

    File.exists?(File.join(@server_dir, "_posts", @report_name)).should == true
    File.exists?(File.join(@server_dir, "data", "report")).should == true
  end

  it "should prevent publish when lock file is present" do
    lock_file = File.join(@server_dir, "lock.txt")
    system("touch #{lock_file}")
    content = capture(:stdout) do
      lambda { Hastie::ReportPublisher.start @input }.should raise_error SystemExit
    end

    File.exists?(File.join(@server_dir, "_posts", @report_name)).should_not == true
    File.exists?(File.join(@server_dir, "data", "report")).should_not == true
  end

  it "should add report to _reports.yml" do
    content = capture(:stdout) do
      lambda { Hastie::ReportPublisher.start @input }.should_not raise_error SystemExit
    end
    reports_content = read_file(File.join(@server_dir, "_reports.yml"))
    reports_content.should match /#{File.basename(@report_dir)}/
  end

  # it "should update git repository with new commit" do
  #   content = capture(:stdout) do
  #     lambda { Hastie::ReportPublisher.start @input }.should_not raise_error SystemExit
  #   end

  #   commits = Grit::Repo.new(@server_dir).commits('server',1)
  #   commits[0].message.should match /update with report: report/
  # end

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
  end
end
