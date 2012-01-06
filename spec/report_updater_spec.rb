require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fakefs_helper')
require 'hastie/report_updater'

describe Hastie::ReportUpdater do
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

    # Grit::Repo.init(@server_dir)

    @input = [@report_dir, "--config_file", @config_file, "--server_root", @server_dir]
  end

  after :each do
    FileUtils.rm_r @sandbox if File.exists?(@sandbox)
  end

  it "should copy modified files to report dir" do

    File.open(File.join(@server_dir, "css", "style.css"), 'w') do |file|
      file.puts "brick: house"
    end

    content = capture(:stdout) do
      lambda { Hastie::ReportUpdater.start @input }.should_not raise_error SystemExit
    end

    css_content = read_file(File.join(@report_dir, "css", "style.css"))
    css_content.should match /brick: house/

  end
end
