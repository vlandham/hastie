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

module Hastie
  class IdServer
    def request_id researcher, pi
      "cbio.#{researcher}.1000"
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
    @date = "2011-11-31"
  end

  after :each do
    FileUtils.rm_r @output_dir if File.exists?(@output_dir)
  end

  describe "project directory generation" do
    before :each do
      @report_id = "test.test.100"
      @input = ["-i", @report_id, "-l", "ppp", "-r", "rrr", "-o", @output_dir, "--config_file", @config_file, "--server_root", @server_dir, "--date", @date]
      @expected_report_name = File.join(@output_dir,@report_id, "report", "#{@date}-#{File.basename(@report_id)}")
    end

    after :each do
      FileUtils.rm_r @output_dir if File.exists?(@output_dir)
    end

    it "should create scaffold files in output directory" do
      content = capture(:stdout) do
        lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
      end

      File.exists?(File.join(@output_dir)).should == true
      File.exists?(File.join(@output_dir,@report_id)).should == true
      File.exists?(File.join(@output_dir,@report_id, "report")).should == true
      File.exists?(@expected_report_name + ".textile").should == true

      File.exists?(File.join(@output_dir,@report_id,"data")).should == true
    end

  end

  describe "create overview page" do

    before :each do
      @input = ["--template", "overview", "-i", "sandbox", "-l", "ppp", "-r", "rrr", "-o", @output_dir, "--config_file", @config_file, "--server_root", @server_dir, "--date", @date, "--only_report"]
      @expected_report_name = File.join(@output_dir, "#{@date}-#{File.basename(@output_dir)}")
    end


    it "should create scaffold files in output directory" do
      content = capture(:stdout) do
        lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
      end

      File.exists?(@expected_report_name + ".textile").should == true
    end
  end

  describe "basic functionality" do

    before :each do
      @input = ["-i", "sandbox", "-l", "ppp", "-r", "rrr", "-o", @output_dir, "--config_file", @config_file, "--server_root", @server_dir, "--date", @date, "--only_report"]
      @expected_report_name = File.join(@output_dir, "#{@date}-#{File.basename(@output_dir)}")
      @expected_output_name = File.join(@output_dir, "#{File.basename(@output_dir)}")
    end


    it "should create scaffold files in output directory" do
      content = capture(:stdout) do
        lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
      end

      File.exists?(@expected_report_name + ".textile").should == true
      File.directory?(File.join(@output_dir, "data")).should == true
      File.directory?(File.join(@output_dir, "data", File.basename(@output_dir))).should == true
      File.directory?(File.join(@output_dir, "_layouts")).should == true
      File.directory?(File.join(@output_dir, "css")).should == true
      File.directory?(File.join(@output_dir, "js")).should == true
      File.directory?(File.join(@output_dir, "_plugins")).should == true
      File.directory?(File.join(@output_dir, "_includes")).should == true
      File.exists?(File.join(@output_dir, "_config.yml")).should == true
      File.exists?(File.join(@output_dir, "report.yml")).should == true
      File.exists?(File.join(@output_dir, "index.html")).should == true
    end

    it "should provide link in index file to html page" do
      content = capture(:stdout) do
        lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
      end

      puts content
      index_file = File.join(@output_dir, "index.html")
      File.exists?(index_file).should == true

      index_content = read_file index_file

      index_content.should match /url=\/#{File.basename(@expected_output_name)}.html/

    end

    ["markdown", "textile"].each do |format|
      it "should have default content" do
        @input << "--type" << format
        content = capture(:stdout) do
          lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
        end

        report_file = File.join(@expected_report_name + "." + format)
        File.exists?(report_file).should == true
        report_file_content = read_file report_file

        report_file_content.should match /layout: report/
        report_file_content.should match /title: sandbox/
        report_file_content.should match /data:/
        report_file_content.should match /- data\/#{File.basename(@output_dir)}/
      end
    end

    describe "input options" do
      it "--type" do
        @input << "--type" << "markdown"
        content = capture(:stdout) do
          lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
        end

        File.exists?(File.join(@expected_report_name + ".markdown")).should == true
      end

      it "--analyst" do
        @input << "--analyst" << "mcm"
        content = capture(:stdout) do
          lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
        end
        report_file = File.join(@expected_report_name + ".textile")

        File.exists?(report_file).should == true
        report_file_content = read_file report_file

        report_file_content.should match /analyst: mcm/
      end

      it "--lab" do
        @input << "--lab" << "dad"
        content = capture(:stdout) do
          lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
        end
        report_file = File.join(@expected_report_name + ".textile")

        File.exists?(report_file).should == true
        report_file_content = read_file report_file

        report_file_content.should match /pi: dad/
      end

      it "--researcher" do
        @input << "--researcher" << "odd"
        content = capture(:stdout) do
          lambda { Hastie::ReportGenerator.start @input }.should_not raise_error SystemExit
        end
        report_file = File.join(@expected_report_name + ".textile")

        File.exists?(report_file).should == true
        report_file_content = read_file report_file

        report_file_content.should match /researcher: odd/
      end
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
        lambda { ReportGeneratorChild.start ["-i", project, "-l", "ppp", "-r", "rrr", "--only_report"]}.should raise_error SystemExit
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
