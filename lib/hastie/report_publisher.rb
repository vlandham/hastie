require 'fileutils'
require 'hastie/config_file'
require 'hastie/constants'
require 'hastie/server_reader'

module Hastie
  class ReportPublisher < ServerReader
    def self.banner
      "hastie publish <REPORT_DIR> <OPTIONS>"
    end

    attr_accessor :report_dir
    desc "Publishes report to server"
    argument :name, :type => :string, :default => ".", :desc => "The name report directory"

    def read_report_file
      self.report_dir = File.expand_path(name)
      report_config_file = File.join(report_dir, Hastie.report_config_name)
      if !File.exists? report_config_file
        say "Cannot locate #{Hastie.report_config_name}."
        say "Current directory is not a report."
        exit(1)
      end
      # we get the report filename from this config file
      local_config = ConfigFile.load(report_config_file, :local)
      self.options = local_config.merge(self.options)
    end

    def check_options
      all_valid = true
      required_server_options = ["reports_dir"]
      required_server_options.each do |option|
        if !options[:server] or !options[:server][option]
          say_status "error", "Missing #{option} option from server config", :red
          all_valid = false
        end
      end

      required_local_options = ["report_file", "report_id"]
      required_local_options.each do |option|
        if !options[:local] or !options[:local][option]
          say_status "error", "Missing #{option} option from local config", :red
          all_valid = false
        end
      end

      if !all_valid
        exit(1)
      end
    end

    def set_destination_directory
      self.destination_root = File.join(options[:server_root])
      say_status "note", "root: #{self.destination_root}"
    end

    def copy_report_file
      report_filename = options[:local]["report_file"]
      local_report = File.join(report_dir, report_filename)
      destination_report = File.join(options[:server_root], options[:server]["reports_dir"], report_filename)
      if File.exists? local_report
        say_status "publishing", report_filename
        # FileUtils.cp local_report, destination_report
        command = "cp #{local_report} #{destination_report}"
        pid = Process.fork do
          exec(command)
        end
        Process.waitpid(pid)
      else
        say_status "error", "Report file not found: #{report_filename}", :red
        exit(1)
      end
    end

    def copy_data_directory
      data_dir = File.join(report_dir, DATA_ROOT, options[:local]["report_id"])
      destination_dir = File.join(options[:server_root], DATA_ROOT)
      if File.exists? data_dir
        say_status "publishing", data_dir
        command = "cp -r #{data_dir} #{destination_dir}"
        pid = Process.fork do
          exec(command)
        end
        Process.waitpid(pid)
         # FileUtils.cp_r data_dir, destination_dir
      else
        say_status "warning", "report data directory not found #{data_dir}", :yellow
      end
    end

    def add_to_reports_file
      in_root do
        say_status "note", "modifying #{SERVER_REPORTS_FILE}"
        say_status "note", " to include #{options[:local]["report_id"]}"
        server_report_file = SERVER_REPORTS_FILE
        if !File.exists? server_report_file
          say_status "error", "Cannot find #{SERVER_REPORTS_FILE} file in server directory:", :red
        end
        ConfigFile.append(server_report_file, options[:local]["report_id"])
      end
    end

    def update_git_repo
      in_root do
        say_status "note", "updating git repository"
        repo = Grit::Repo.new(".")
        # ensure we are on the server branch
        repo.git.native :checkout, {}, 'server'
        repo = Grit::Repo.new(".")
        if repo.head.name != "server"
          say_status "error", "Remote git not on server branch", :red
          say_status "error", "Please git checkout server", :red
          say_status "error", "Current branch: #{repo.head.name}", :red
          exit(1)
        end
        all_files = Dir.glob("./**")
        repo.add(all_files)
        repo.commit_all("update with report: #{options[:local]["report_id"]}")
      end
    end

    def publish_with_jekyll
      in_root do
        say_status "publishing", "updating server reports", :yellow
        config_file = File.expand_path(File.join(FileUtils.getwd, Hastie.watch_config_file))
        server_config_file = File.expand_path(File.join(FileUtils.getwd, Hastie.publish_config_file))
        if File.exists?(server_config_file)
          config_file = server_config_file
        end
        say_status "config", config_file, :yellow
        command = "jekyll --config #{config_file}"
        pid = Process.fork do
          exec(command)
        end
        Process.waitpid(pid)
      end
    end
  end
end
