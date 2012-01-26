require 'fileutils'
require 'hastie/constants'
require 'hastie/config_file'
require 'thor/group'

module Hastie
  class ReportWatcher < Thor::Group
    include Thor::Actions

    desc "Watches Directory Using Jekyll"
    argument :path, :type => :string, :default => ".", :desc => "The path to the report directory"

    attr_accessor :report_dir

    # this is done just as a double check that we are in a report directory
    def check_report_file
      self.report_dir = File.expand_path(path)
      report_config_file = File.join(report_dir, Hastie.report_config_name)
      if !File.exists? report_config_file
        say_status "error","Cannot locate #{Hastie.report_config_name}.", :red
        say_status "error","Directory #{self.report_dir} is not a report.", :red
        exit(1)
      end
    end

    def set_root
      self.destination_root = self.report_dir
    end

    def read_config_file
      config_file = File.join(self.report_dir, Hastie.watch_config_file)
      if !File.exists? config_file
        say_status "error", "Cannot find #{config_file}", :red
        say_status "error","Directory #{self.report_dir} is not a report.", :red
        exit(1)
      end
      local_config = ConfigFile.load(config_file, :local)
      self.options = local_config.merge(self.options)
    end

    def start_jekyll
      port = self.options["local"]["server_port"] || "4000"
      url = "http://0.0.0.0:#{port}"
      say_status "open", url

      # pid = fork do
      #   begin
      #     require 'launchy'
      #     sleep 4
      #     Launchy.open(url)
      #   rescue LoadError
      #   rescue
      #   end
      # end

      in_root do
        exec("jekyll --auto --server")
      end
    end
  end
end
