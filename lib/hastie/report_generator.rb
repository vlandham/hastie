require 'fileutils'
require 'hastie/config_file'
require 'hastie/constants'
require 'hastie/server_reader'

module Hastie
  class ReportGenerator < ServerReader

    attr_accessor :report_id, :title, :analyst, :researcher, :pi

    desc "Creates framework for new report"
    argument :name, :type => :string, :desc => "The name of the new report. no spaces"
    class_option :type, :aliases => "-t", :desc => "Type of report to generate"
    class_option :analyst, :aliases => "-a", :desc => "Analyst generating the report"
    class_option :researcher, :aliases => "-r", :desc => "Researcher the report is for"
    class_option :pi, :aliases => "-p", :desc => "PI the researcher is under"

    def setup_variables
      options[:type] ||= "markdown"
      options[:name] = name
      self.title = name.gsub("_", " ").capitalize
      options[:title] = self.title
      # report_id will be used internally in case the name turns
      # out to be too loose to use
      self.report_id = name

      options[:report_id] = self.report_id

      options[:analyst] ||= "unknown"
      self.analyst = options[:analyst] || "unknown"
      options[:researcher] ||= "unknown"
      options[:pi] ||= "unknown"
      options[:data_dir] ||= data_dir
    end

    def check_name_availible
      puts options[:published_reports]
      if options[:published_reports] and options[:published_reports].include? report_id
        say_status "error", "Sorry, the #{report_id} is already a published report", :red
        say_status "error", "Please run again with a different name", :red
        exit(1)
      end
    end

    def create_report_file
      say_status "create", "report directory: #{options[:report_id]}"
      extension = determine_extension(options[:type])
      template_file = "templates/report.#{extension}.tt"
      report_filename = "#{report_id}.#{extension}"
      template template_file, "#{report_id}/#{report_filename}"
      options[:report_file] = report_filename
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
        static_path = File.join(options[:server_root], static_file)
        destination_root = File.join(self.destination_root, report_id)
        if File.exists? static_path
          say_status "copy", "#{static_path} to #{File.basename(destination_root)}"
          FileUtils.cp_r static_path, destination_root
        end
      end
    end

    def write_config_file
      output_config_file = File.join report_id, Hastie.report_config_name
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
    end
  end
end
