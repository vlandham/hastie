require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'hastie/server_generator'


describe Hastie::ServerGenerator do

  def read_file file
    if File.exists? file
      File.open(file, 'r').read
    else
      ""
    end
  end

  before :each do
    @template_server_dir = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "server"))
    @output_dir = File.expand_path(File.join(File.dirname(__FILE__), "sandbox"))
    @input = [@output_dir]
  end

  after :each do
    FileUtils.rm_r @output_dir if File.exists?(@output_dir)
  end

  it "should create server scaffold in output directory" do
    content = capture(:stdout) do
      lambda { Hastie::ServerGenerator.start @input }.should_not raise_error SystemExit
    end

    template_files = Dir.glob(File.join(@template_server_dir, "*"))

    template_files.each do |file|
      base_file = file.gsub(@template_server_dir, @output_dir)
      File.exists?(base_file).should == true
    end
  end

  it "should put static section in _config.yml" do
    content = capture(:stdout) do
      lambda { Hastie::ServerGenerator.start @input }.should_not raise_error SystemExit
    end

    config_file = File.join(@output_dir, "_config.yml")
    File.exists?(config_file).should == true
    config_content = read_file config_file
    config_content.should match /static:/
  end

  it "should put reports_dir section in _config.yml" do
    content = capture(:stdout) do
      lambda { Hastie::ServerGenerator.start @input }.should_not raise_error SystemExit
    end

    config_file = File.join(@output_dir, "_config.yml")
    File.exists?(config_file).should == true
    config_content = read_file config_file
    config_content.should match /reports_dir:/
  end

  it "should be a git repository" do
    content = capture(:stdout) do
      lambda { Hastie::ServerGenerator.start @input }.should_not raise_error SystemExit
    end
    git_proof = File.join(@output_dir, ".git")
    File.directory?(git_proof).should == true
  end
end

