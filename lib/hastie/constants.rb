module Hastie
  CONFIG_FILE = File.expand_path(File.join("~", ".hastie"))
  SERVER_REPORTS_FILE = "_reports.yml"
  SERVER_CONFIG_FILE = "_config.yml"
  SERVER_PUBLISH_CONFIG_FILE = "_server_config.yml"

  DATA_ROOT = "data"
  REPORT_CONFIG_FILE = "report.yml"
  DEFAULT_REPORT_DIR = "report"
  DEFAULT_ID_ISSUER = "cbio"
  DEFAULT_ID_SERVER = "http://projectid"

  def self.config_file
    CONFIG_FILE
  end

  def self.report_config_name
    REPORT_CONFIG_FILE
  end

  def self.watch_config_file
    SERVER_CONFIG_FILE
  end

  def self.publish_config_file
    SERVER_PUBLISH_CONFIG_FILE
  end

  def self.default_report_dir
    DEFAULT_REPORT_DIR
  end

  def self.id_issuer
    DEFAULT_ID_ISSUER
  end

  def self.id_server
    DEFAULT_ID_SERVER
  end
end
