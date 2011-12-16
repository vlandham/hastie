require 'fileutils'
require 'hastie/config_file'
require 'hastie/constants'
require 'hastie/server_reader'

module Hastie
  class ReportPublisher < ServerReader
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
        FileUtils.cp local_report, destination_report
      else
        say_status "error", "Report file not found: #{report_filename}", :red
        exit(1)
      end
    end

    def copy_img_directory
      img_dir = File.join(report_dir, IMGS_ROOT, options[:local]["report_id"])
      destination_img_dir = File.join(options[:server_root], IMGS_ROOT)
      if File.exists? img_dir
        say_status "publishing", img_dir
        FileUtils.cp_r img_dir, destination_img_dir
      else
        say_status "warning", "report image directory not found #{img_dir}"
      end
    end

    def copy_data_directory
      data_dir = File.join(report_dir, DATA_ROOT, options[:local]["report_id"])
      destination_dir = File.join(options[:server_root], DATA_ROOT)
      if File.exists? data_dir
        say_status "publishing", data_dir
        FileUtils.cp_r data_dir, destination_dir
      else
        say_status "warning", "report data directory not found #{data_dir}"
      end
    end

    def update_git_repo
      in_root do
        say_status "note", "updating git repository"
        repo = Grit::Repo.new(".")
        all_files = Dir.glob("./**")
        repo.add(all_files)
        repo.commit_all("update with report: #{options[:local]["report_id"]}")
      end
    end
  end
end
