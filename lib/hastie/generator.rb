require 'thor/group'
require 'yaml'
require 'hastie/hash_extras'

module Hastie
  class ReportGenerator < Thor::Group
    include Thor::Actions
    attr_accessor :title, :analyst, :researcher, :pi

    CONFIG_FILE = File.expand_path(File.join("~", ".hastie"))

    DATA_ROOT = "data"
    IMGS_ROOT = "imgs"
    PUBLISH_ROOT_CONFIG = :publish_root

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
      config = YAML.load(File.read(config_file))
      puts options.class
      if config
        say "loading config file"
        config = Thor::CoreExt::HashWithIndifferentAccess.new(config)
        self.options = config.merge(self.options)
      end
    end

    def setup_variables
      self.title = name.gsub("_", " ").capitalize
      self.analyst = options[:analyst] || "unknown"
      self.researcher = options[:researcher] || "unknown"
      self.pi = options[:pi] || "unknown"
    end


    def check_name_availible
      if !File.directory? options[:publish_root]
        say "Cannot find publishing directory:"
        say options[:publish_root]
        say "Please modify this path to point to publishing root directory"
        exit(1)
      end

    end

    def create_report_file
      extension = determine_extension(options[:type])
      template_file = "templates/report.#{extension}.tt"
      template template_file, "#{name}/#{name}.#{extension}"
    end

    def create_image_dir
      create_file File.join(name, data_dir, ".gitignore"), :verbose => true
    end

    def create_data_dir
      create_file File.join(name, imgs_dir, ".gitignore"), :verbose => true
    end

    def fetch_static_files
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
