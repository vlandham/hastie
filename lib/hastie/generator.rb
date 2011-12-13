require 'thor/group'

module Hastie
  class ReportGenerator < Thor::Group
    include Thor::Actions
    attr_accessor :title, :analyst, :researcher, :pi

    DATA_ROOT = "data"
    IMGS_ROOT = "imgs"

    desc "Creates framework for new report"
    argument :name, :type => :string, :desc => "The name of the new report. no spaces"
    class_option :type, :aliases => "-t", :default => :markdown, :desc => "Type of report to generate"
    class_option :analyst, :aliases => "-a", :default => "jfv", :desc => "Analyst generating the report"
    class_option :researcher, :aliases => "-r", :default => "uknown", :desc => "Researcher the report is for"
    class_option :pi, :aliases => "-p", :default => "uknown", :desc => "PI the researcher is under"

    def self.source_root
      File.dirname(__FILE__)
    end

    def setup
      self.title = name.gsub("_", " ").capitalize
      self.analyst = options[:analyst]
      self.researcher = options[:researcher]
      self.pi = options[:pi]
    end

    def check_name_availible
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
    end
  end
end
