class FakeFsHelper
  CONFIG_FILE = "/tmp/.hastie"
  SERVER_DIR = "/sites/test_server"
  REPORTS_FILE = "_reports.yml"
  SERVER_CONFIG_FILE = "_config.yml"

  def self.read_file file
    if File.exists? file
      File.open(file, 'r').read
    else
      ""
    end
  end

  def self.stub_config_file config_file = CONFIG_FILE, server_dir = SERVER_DIR
    FileUtils.mkdir(File.dirname(config_file))
    File.open(config_file, 'w') do |file|
      file.puts "server_root: #{server_dir}"
    end
  end

  def self.stub_server_dir dir = SERVER_DIR
    FileUtils.mkdir_p dir
  end

  def self.stub_server_config dir = SERVER_DIR
    stub_server_dir dir
    File.open(File.join(dir, SERVER_CONFIG_FILE), 'a') do |file|
      file.puts ""
    end
  end

  def self.add_reports_dir dir = SERVER_DIR
    stub_server_config dir
    File.open(File.join(dir, SERVER_CONFIG_FILE), 'a') do |file|
      file.puts "reports_dir: _posts"
    end
  end

  def self.add_static_files dir = SERVER_DIR
    stub_server_config dir
    static_dirs = ["css", "js", "_layouts", "_includes", "_plugins"]
    static_files = ["_config.yml"]
    File.open(File.join(dir, SERVER_CONFIG_FILE), 'a') do |file|
      file.puts "static:"
      static_dirs.each {|sdir| file.puts "- #{sdir}"}
      static_files.each {|f| file.puts "- #{f}"}
    end

    static_dirs.each {|sdir| FileUtils.mkdir File.join(dir, sdir)}
    static_files.each {|sfile| FileUtils.touch File.join(dir, sfile)}
  end

  def self.stub_reports_file dir = SERVER_DIR
    stub_server_dir dir
    File.open(File.join(dir, REPORTS_FILE), 'a') do |file|
      file.puts ""
    end
  end

  def self.add_published_report report_id, dir = SERVER_DIR
    stub_reports_file dir
    File.open(File.join(dir, REPORTS_FILE), 'a') do |file|
      file.puts "- #{report_id}"
    end
  end
end
