require 'fileutils'
require 'thor/group'
require 'hastie/constants'
module Hastie
  class ConfigGenerator < Thor::Group
    include Thor::Actions

    def self.banner
      "hastie config [SERVER_ROOT] <OPTIONS>"
    end

    argument :server_root, :type => :string, :desc => "Root path of server location"
    class_option :path, :aliases => "-p", :desc => "Root directory of where the config file will be written to", :default => File.expand_path("~")
    class_option :name, :aliases => "-n", :desc => "Name of the config file", :default => ".hastie"
    class_option :analyst, :aliases => "-a", :desc => "Analyst for reports generated with this config file"
    class_option :type, :aliases => "-t", :desc => "Default format of reports to generate", :default => "textile"

    def self.source_root
      File.dirname(__FILE__)
    end


    def check_server_root
      if !File.directory? server_root
        say_status "error", "#{server_root} is not a directory", :red
        say_status "error", "Please use full path to server directory", :red
        exit(1)
      end
    end

    def create_config_file
      output_file = File.join(options[:path], options[:name])
      template "templates/hastie_config.tt", output_file
    end

  end
end
