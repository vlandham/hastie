class FakeFsHelper
  CONFIG_FILE = "/tmp/.hastie"
  SERVER_DIR = "/sites/test_server"

  def self.stub_config_file
    FileUtils.mkdir(File.dirname(CONFIG_FILE))
    File.open(CONFIG_FILE, 'w') do |file|
      file.puts "server_root: #{SERVER_DIR}"
    end
  end

  def self.stub_server_dir
    FileUtils.mkdir_p SERVER_DIR
  end

  def self.stub_server_config
    stub_server_dir
    File.open(File.join(SERVER_DIR, "_config.yml"), 'w') do |file|
      file.puts ""
    end
  end

  def self.stub_reports_file
    stub_server_dir
    File.open(File.join(SERVER_DIR, "_reports.yml"), 'w') do |file|
      file.puts ""
    end
  end
end
