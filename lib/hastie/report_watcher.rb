require 'fileutils'
require 'hastie/constants'
require 'hastie/config_file'
require 'thor/group'

module Hastie
  class ReportWatcher < Thor::Group
    desc "Watches Directory Using Jekyll"
    argument :path, :type => :string, :default => ".", :desc => "The path to the report directory"

    attr_accessor :report_dir

    # this is done just as a double check that we are in a report directory
    def check_report_file
      self.report_dir = File.expand_path(name)
      report_config_file = File.join(report_dir, Hastie.report_config_name)
      if !File.exists? report_config_file
        say_status "error","Cannot locate #{Hastie.report_config_name}.", :red
        say_status "error","Current directory is not a report.", :red
        exit(1)
      end
    end

    def read_config_file
      config_file = File.join(self.report_dir, Hastie.watch_config_file)
      if !File.exists? config_file
        say_status "error", "Cannot find #{config_file}", :red
        say_status "error","Current directory is not a report.", :red
        exit(1)
      end
      local_config = ConfigFile.load(report_config_file, :local)
      self.options = local_config.merge(self.options)
    end

    def start_jekyll
      puts self.options
        # puts "Starting Jekyll..."
        # system("jekyll --auto --server")
    end
  end
end
