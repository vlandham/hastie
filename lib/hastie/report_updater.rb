require 'fileutils'
require 'hastie/config_file'
require 'hastie/constants'
require 'hastie/server_reader'

module Hastie
  class ReportUpdater < ServerReader
    def self.banner
      "hastie update <REPORT_DIR> <OPTIONS>"
    end

    desc "Updates local files from remote server"
    argument :name, :type => :string, :default => ".", :desc => "The name report directory"

    def read_report_file
      self.destination_root = name
      report_config_file = File.join(self.destination_root, Hastie.report_config_name)
      if !File.exists? report_config_file
        say "Cannot locate #{Hastie.report_config_name}."
        say "Report directory does not contain report"
        say "#{File.expand_path(self.destination_root)}"
        exit(1)
      end
      # we get the report filename from this config file
      local_config = ConfigFile.load(report_config_file, :local)
      self.options = local_config.merge(self.options)
    end

    def fetch_static_files
      options[:server]["static"] ||= []
      options[:server]["static"].each do |static_file|
        static_path = File.join(options[:server_root], static_file)
        if File.exists? static_path
          say_status "copy", "#{static_path} to #{File.basename(destination_root)}"
          FileUtils.cp_r static_path, self.destination_root
        end
      end
    end
  end
end
