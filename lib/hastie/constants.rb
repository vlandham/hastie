module Hastie
  CONFIG_FILE = File.expand_path(File.join("~", ".hastie"))
  SERVER_REPORTS_FILE = "_reports.yml"
  SERVER_CONFIG_FILE = "_config.yml"
  SERVER_PUBLISH_CONFIG_FILE = "_server_config.yml"

  DATA_ROOT = "data"
  REPORT_CONFIG_FILE = "report.yml"

  def self.config_file
    CONFIG_FILE
  end

  def self.report_config_name
    REPORT_CONFIG_FILE
  end
end
