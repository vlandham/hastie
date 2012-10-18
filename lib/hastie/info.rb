require 'fileutils'
require 'find'
require 'hastie/constants'
require 'hastie/config_file'
require 'thor/group'

module Hastie
  class Info < Thor::Group
    include Thor::Actions

    desc "Provides Information about Hastie subdirectories"
    argument :path, :type => :string, :default => ".", :desc => "The path to start search from"

    attr_accessor :report_file_paths

    # this is done just as a double check that we are in a report directory
    def find_reports
      search_path = File.expand_path(path)
      Find.find(search_path) do |path|
        if path ~= /^\d{4}.*\.textile/
          self.report_file_paths << path
        end
      end
    end


    def print_paths
      report_file_paths.each do |report_file|
        puts report_file
      end
    end

  end
end
