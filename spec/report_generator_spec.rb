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
