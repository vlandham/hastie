require 'thor/group'
require 'yaml'
require 'hastie/config_file'
require 'fileutils'

module Hastie
  class ReportGenerator < Thor::Group
    include Thor::Actions
    attr_accessor :report_id, :title, :analyst, :researcher, :pi

    CONFIG_FILE = File.expand_path(File.join("~", ".hastie"))

    DATA_ROOT = "data"
    IMGS_ROOT = "imgs"
    REPORT_CONFIG_FILE = "report.yml"

    SERVER_REPORTS_FILE = "_reports.yml"
    SERVER_CONFIG_FILE = "_config.yml"

    desc "Creates framework for new report"
    argument :name, :type => :string, :desc => "The name of the new report. no spaces"
    class_option :type, :aliases => "-t", :desc => "Type of report to generate"
    class_option :analyst, :aliases => "-a", :desc => "Analyst generating the report"
    class_option :researcher, :aliases => "-r", :desc => "Researcher the report is for"
    class_option :pi, :aliases => "-p", :desc => "PI the researcher is under"

    def self.source_root
      File.dirname(__FILE__)
    end


    def read_config_file
      if !File.exists? config_file
        say "No config file found. Please create #{config_file}"
        exit(1)
      end
      config = ConfigFile.load(config_file)
      self.options = config.merge(self.options)
    end

    def get_publish_config
      # First check if the publishing directory exists
      if !File.directory? options[:publish_root]
        say "Cannot find publishing directory:"
        say options[:publish_root]
        say "Please modify \'publish_root\' to point to publishing root directory"
        exit(1)
      end

      # Check for config file inside publish_root
      publish_config_file = File.join(options[:publish_root], SERVER_CONFIG_FILE)
      if !File.exists? publish_config_file
        say "Cannot find config file in publishing directory:"
        say publish_config_file
        say ""
        say "Are you sure #{options[:publish_root]} is a valid publish directory?"
        exit(1)
      end

      # Check for reports file inside publish_root
      publish_report_file = File.join(options[:publish_root], SERVER_REPORTS_FILE)
      if !File.exists? publish_report_file
        say "Cannot find report file in publishing directory:"
        say publish_report_file
        say ""
        say "Are you sure #{options[:publish_root]} is a valid publish directory?"
        exit(1)
      end

      # merge the publish config and report file
      # put them in their own 'namespace' to avoid
      # collisions with existing configs
      publish_config = ConfigFile.load(publish_config_file, :server)
      self.options = publish_config.merge(self.options)

      publish_reports = ConfigFile.load(publish_report_file, :reports)
      self.options = publish_reports.merge(self.options)
    end

    def setup_variables
      options[:name] = name
      self.title = name.gsub("_", " ").capitalize
      options[:title] = self.title
      # report_id will be used internally in case the name turns
      # out to be too loose to use
      self.report_id = name
      options[:report_id] = self.report_id
      self.analyst = options[:analyst] || "unknown"
      self.researcher = options[:researcher] || "unknown"
      self.pi = options[:pi] || "unknown"
    end

    def check_name_availible
      if options[:published_reports] and options[:published_reports].include? report_id
        say "Sorry, the report name #{report_id} is already a published report"
        say "Please run again with a different name"
        exit(1)
      end
    end

    def create_report_file
      extension = determine_extension(options[:type])
      template_file = "templates/report.#{extension}.tt"
      template template_file, "#{report_id}/#{report_id}.#{extension}"
    end

    def create_image_dir
      create_file File.join(self.report_id, data_dir, ".gitignore"), :verbose => true
    end

    def create_data_dir
      create_file File.join(self.report_id, imgs_dir, ".gitignore"), :verbose => true
    end

    def fetch_static_files
      options[:server]["static"] ||= []
      options[:server]["static"].each do |static_file|
        static_path = File.join(options[:publish_root], static_file)
        destination_root = File.join(self.destination_root, report_id)
        if File.exists? static_path
          say_status "copy", "#{static_path} to #{File.basename(destination_root)}"
          FileUtils.cp_r static_path, destination_root
        end
      end
    end

    def write_config_file
      output_config_file = File.join report_id, REPORT_CONFIG_FILE
      say_status "write", "#{File.basename(output_config_file)}"
      ConfigFile.write(output_config_file, options)
    end

    no_tasks do
      def determine_extension report_type
        extension = case report_type.to_sym
                    when :markdown,:md
                      "markdown"
                    when :textile
                      "textile"
                    when :html,:htm
                      "html"
                    else
                      say "WARNING: #{report_type} not a valid type. Defaulting to markdown"
                      "markdown"
                    end
        extension
      end

      def data_dir
        File.join(DATA_ROOT, name)
      end

      def imgs_dir
        File.join(IMGS_ROOT, name)
      end

      def config_file
        CONFIG_FILE
      end
    end
  end
end
