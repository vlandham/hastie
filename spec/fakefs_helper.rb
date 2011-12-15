class FakeFsHelper
  CONFIG_FILE = "/tmp/.hastie"
  SERVER_DIR = "/sites/test_server"

  def self.stub_config_file server_dir = SERVER_DIR
    FileUtils.mkdir(File.dirname(CONFIG_FILE))
    File.open(CONFIG_FILE, 'w') do |file|
      file.puts "server_root: #{server_dir}"
    end
  end

  def self.stub_server_dir dir = SERVER_DIR
    FileUtils.mkdir_p dir
  end

  def self.stub_server_config dir = SERVER_DIR
    stub_server_dir dir
    File.open(File.join(dir, "_config.yml"), 'w') do |file|
      file.puts ""
    end
  end

  def self.stub_reports_file dir = SERVER_DIR
    stub_server_dir dir
    File.open(File.join(dir, "_reports.yml"), 'w') do |file|
      file.puts ""
    end
  end
end
