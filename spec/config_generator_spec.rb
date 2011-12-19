require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fakefs_helper')
require 'hastie/config_generator'

describe Hastie::ConfigGenerator do
  def read_file file
    if File.exists? file
      File.open(file, 'r').read
    else
      ""
    end
  end

  before :each do
    @server_dir = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "server"))
    @output_dir = File.expand_path(File.join(File.dirname(__FILE__), "sandbox"))
    @name = "hastie_config_gen"
    @config_file = File.join(@output_dir, @name)
    @input = [@server_dir, "--path", @output_dir, "--name", @name]
    FileUtils.mkdir_p @output_dir
  end

  after :each do
    FileUtils.rm_r @output_dir if File.exists?(@output_dir)
  end

  it "should have server_root" do
    content = capture(:stdout) do
      lambda { Hastie::ConfigGenerator.start @input }.should_not raise_error SystemExit
    end

    content = read_file @config_file
    content.should match /server_root: #{@server_dir}/

  end

  describe "config flags" do
    it "--analyst" do
      @input << "--analyst" << "dog"
      content = capture(:stdout) do
        lambda { Hastie::ConfigGenerator.start @input }.should_not raise_error SystemExit
      end

      content = read_file @config_file
      content.should match /analyst: dog/
    end

    it "--type" do
      @input << "--type" << "textile"
      content = capture(:stdout) do
        lambda { Hastie::ConfigGenerator.start @input }.should_not raise_error SystemExit
      end

      content = read_file @config_file
      content.should match /type: textile/
    end
  end
end

describe Hastie::ConfigGenerator, fakefs: true do
  before :each do
    @server_root = "/tmp/server/root"
    @input = [@server_root]
  end

  describe "invalid server_root" do
    it "should error if server_root does not exist" do
      content = capture(:stdout) do
        lambda { Hastie::ConfigGenerator.start @input }.should raise_error SystemExit
      end
      content.should match /not a directory/
    end
  end

  describe "valid server_root" do
    before :each do
      FileUtils.mkdir_p @server_root
      #
      # CLONE: copies files from real fs to fakefs.
      # TODO: use clone in other specs to copy the templates directory
      #
      FakeFS::FileSystem.clone(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "hastie", "templates")))
    end

    it "should not error if server_root does not exist" do
      content = capture(:stdout) do
        lambda { Hastie::ConfigGenerator.start @input }.should_not raise_error SystemExit
      end
    end

    it "should create hastie config file" do
      content = capture(:stdout) do
        lambda { Hastie::ConfigGenerator.start @input }.should_not raise_error SystemExit
      end
      File.exists?(File.expand_path("~/.hastie")).should == true
    end

    it "--path" do
      path = "/alt/file/location"
      @input << "--path" << path
      # Hastie::ConfigGenerator.start @input
      content = capture(:stdout) do
        lambda { Hastie::ConfigGenerator.start @input }.should_not raise_error SystemExit
      end

      File.exists?("#{path}/.hastie").should == true
    end

    it "--name" do
      path = "/alt/file/location"
      name = "hastier"
      @input << "--path" << path << "--name" << name
      # Hastie::ConfigGenerator.start @input
      content = capture(:stdout) do
        lambda { Hastie::ConfigGenerator.start @input }.should_not raise_error SystemExit
      end

      File.exists?("#{path}/#{name}").should == true
    end
  end


end

