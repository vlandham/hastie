require 'fileutils'
require 'hastie/constants'
require 'hastie/config_file'
require 'hastie/id_server'
require 'thor/group'

module Hastie
  class IdMaker < Thor::Group
    include Thor::Actions

    def self.banner
      "hastie id -l [LAB] -r [RESERACHER] <OPTIONS>"
    end

    attr_accessor :report_id, :title, :researcher, :lab

    desc "Creates framework for new report"
    class_option :lab, :aliases => "-l", :required => true, :desc => "Lab the researcher is under"
    class_option :researcher, :aliases => "-r", :required => true, :desc => "Researcher the report is for"
    class_option :analyst, :aliases => "-a", :desc => "Analyst generating the report"
    class_option :link, :desc => "Link for the new project id"
    class_option :description, :aliases => '-d', :desc => "description to add"

    class_option :id_server, :aliases => '-s', :desc => "URL of ID server to use", :default => Hastie.id_server
    class_option :id_issuer, :aliases => '-i', :desc => "ID domain to use", :default => Hastie.id_issuer

    def create_id
      if options[:id_server] and options[:id_issuer]
        id_server = Hastie::IdServer.new(options[:id_server], options[:id_issuer])
        server_response = id_server.request_id(options[:lab], options[:researcher], options)
        say_status "response", "here is the server response", :yellow
        puts server_response.inspect
      else
        say_status "error", "No ID server found", :red
        say_status "error", " Provide --id_server and --id_issuer", :red
        exit(1)
      end
    end
  end
end

