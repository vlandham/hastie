require 'yaml'
require 'fileutils'
require 'thor/group'
require 'hastie/config_file'
require 'hastie/constants'

module Hastie
  class ServerReader < Thor::Group
    include Thor::Actions
    class_option :config_file, :aliases => "-c", :desc => "Path to .hastie config file", :default => Hastie.config_file
    class_option :server_root, :aliases => "-s", :desc => "Root directory of the server to read / publish to"

    no_tasks do
      def config_file
        @config_file ||= if options[:config_file]
                           File.expand_path(options[:config_file])
                           else
                             Hastie.config_file
                           end
        @config_file
      end
    end

    def self.source_root
      File.dirname(__FILE__)
    end

    # Tries to access users config file
    # loads contents into the options hash
    def read_config_file
      say_status "note", "config file: #{self.config_file}"
      if !File.exists? self.config_file
        say "No config file found. Please create #{self.config_file}"
        exit(1)
      end
      config = ConfigFile.load(self.config_file)
      self.options = config.merge(self.options)
    end

    # Tries to access the servers
    def get_server_config
      say_status "note", "server root: #{options[:server_root]}"
      # First check if the server directory exists
      if !File.directory? options[:server_root]
        say_status "error", "Cannot find server directory:", :red
        say options[:server_root]
        say "Please modify \'server_root\' to point to server root directory"
        exit(1)
      end

      # Check for config file inside server_root
      server_config_file = File.join(options[:server_root], SERVER_CONFIG_FILE)
      if !File.exists? server_config_file
        say_status "error", "Cannot find #{SERVER_CONFIG_FILE} file in server directory:", :red
        say server_config_file
        say ""
        say "Are you sure #{options[:server_root]} is a valid server directory?"
        exit(1)
      end

      # Check for reports file inside server_root
      server_report_file = File.join(options[:server_root], SERVER_REPORTS_FILE)
      if !File.exists? server_report_file
        say_status "error", "Cannot find #{SERVER_REPORTS_FILE} file in server directory:", :red
        say server_report_file
        say ""
        say "Are you sure #{options[:server_root]} is a valid server directory?"
        exit(1)
      end

      # merge the server config and report file
      # put them in their own 'namespace' to avoid
      # collisions with existing configs
      server_config = ConfigFile.load(server_config_file, :server)
      self.options = server_config.merge(self.options)

      server_reports = ConfigFile.load(server_report_file, :published_reports)
      self.options = server_reports.merge(self.options)
    end
  end
end
