require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fakefs_helper')
require 'hastie/report_generator'

class ReportGeneratorChild < Hastie::ReportGenerator
  no_tasks do
    def config_file
      FakeFsHelper::CONFIG_FILE
    end
  end
end

describe Hastie::ReportGenerator do

  def read_file file
    if File.exists? file
      File.open(file, 'r').read
    else
      ""
    end
  end

  before :each do
    @config_file = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "hastie_config"))
    @server_dir = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "server"))
    @output_dir = File.expand_path(File.join(File.dirname(__FILE__), "sandbox"))
    @input = [@output_dir, "--config_file", @config_file, "--server_root", @server_dir]
  end

  after :each do
    FileUtils.rm_r @output_dir if File.exists?(@output_dir)
  end

  it "should create scaffold files in output directory" do
    content = capture(:stdout) do
      lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
    end

    File.exists?(File.join(@output_dir, File.basename(@output_dir) + ".textile")).should == true
    File.directory?(File.join(@output_dir, "imgs")).should == true
    File.directory?(File.join(@output_dir, "imgs", File.basename(@output_dir))).should == true
    File.directory?(File.join(@output_dir, "data")).should == true
    File.directory?(File.join(@output_dir, "data", File.basename(@output_dir))).should == true
    File.directory?(File.join(@output_dir, "_layouts")).should == true
    File.directory?(File.join(@output_dir, "css")).should == true
    File.directory?(File.join(@output_dir, "js")).should == true
    File.directory?(File.join(@output_dir, "_plugins")).should == true
    File.directory?(File.join(@output_dir, "_includes")).should == true
    File.exists?(File.join(@output_dir, "_config.yml")).should == true
  end

  describe "input options" do
    it "--type" do
      @input << "--type" << "markdown"
      content = capture(:stdout) do
        lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
      end

      File.exists?(File.join(@output_dir, File.basename(@output_dir) + ".markdown")).should == true
    end

    it "--analyst" do
      @input << "--analyst" << "mcm"
      content = capture(:stdout) do
        lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
      end
      report_file = File.join(@output_dir, File.basename(@output_dir) + ".textile")

      File.exists?(report_file).should == true
      report_file_content = read_file report_file

      report_file_content.should match /analyst: mcm/
    end

    it "--pi" do
      @input << "--pi" << "dad"
      content = capture(:stdout) do
        lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
      end
      report_file = File.join(@output_dir, File.basename(@output_dir) + ".textile")

      File.exists?(report_file).should == true
      report_file_content = read_file report_file

      report_file_content.should match /pi: dad/
    end

    it "--researcher" do
      @input << "--researcher" << "odd"
      content = capture(:stdout) do
        lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
      end
      report_file = File.join(@output_dir, File.basename(@output_dir) + ".textile")

      File.exists?(report_file).should == true
      report_file_content = read_file report_file

      report_file_content.should match /researcher: odd/
    end
  end
end

describe Hastie::ReportGenerator, fakefs: true do
  before :each do
    # tested in server_reader_spec.rb
    FakeFsHelper.stub_config_file
    FakeFsHelper.stub_reports_file
    FakeFsHelper.stub_server_config
  end

  describe "existing report present" do
    it "should report existing report and exit" do
      project = "existing_project"

      FakeFsHelper.add_published_report project

      content = capture(:stdout) do
        lambda { ReportGeneratorChild.start [project] }.should raise_error SystemExit
      end
      content.should match /#{project} is already/
    end
  end

  describe "create report framework" do
    it "should create template report file" do
      project = "fake_project_name"

      # content = capture(:stdout) {ReportGeneratorChild.start [project] }
      # puts content
      # File.exists?(File.join(project, "#{project}.markdown")).should == true

    end
  end
end
