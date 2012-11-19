require 'fileutils'
require 'find'
require 'hastie/constants'
require 'hastie/config_file'
require 'thor/group'

require 'yaml'

module Hastie
  class Report

    attr_accessor :file_path, :content, :data, :meta

    def initialize file_path
      self.data = {}
      self.file_path = file_path
      read(file_path)

      self.meta = {}
      report_yaml_file = File.join(File.dirname(file_path), "report.yml")
      if File.exists? report_yaml_file
        read_report_yaml_file(report_yaml_file)
      end
    end

    # code stolen from jekyll lib/jekyll/convertible.rb
    def read file_path
      self.content = File.read(file_path)

      begin
        if self.content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
          self.content = $POSTMATCH

          self.data = YAML.load($1)
        end
      rescue ArgumentError
        STDERR.puts "The contents of post #{file_path} are causing some problems. Most likely it has characters that are invalid UTF-8. Please correct this and try again."
      rescue Psych::SyntaxError
        puts "YML Exception reading #{file_path}"
      rescue => e
        puts "YAML Exception reading #{file_path}: #{e.message}"
      end
    end

    def read_report_yaml_file file_path
      self.meta = YAML.load(File.read(file_path))
    end
  end

  class Info < Thor::Group
    include Thor::Actions

    desc "Provides Information about Hastie subdirectories"
    argument :path, :type => :string, :default => ".", :desc => "The path to start search from"

    attr_accessor :report_file_paths, :reports, :results

    def setup
      self.report_file_paths = []
      self.reports = []
      self.results = []
    end

    # this is done just as a double check that we are in a report directory
    def find_reports
      search_path = File.expand_path(path)
      # puts "searching #{search_path}"
      # puts ""
      Find.find(search_path) do |loc_path|
        if loc_path =~ /\d{4}.*\.textile$/
          self.report_file_paths << loc_path
        end
      end

      self.report_file_paths.sort_by! {|file| File.mtime(file)}
    end

    def parse_reports
      self.report_file_paths.each do |report_file|
        reports << Report.new(report_file)
      end
    end

    def collect_results
      self.results << ["id", "pi", "researcher", "analyst", "date", "file"]
      self.reports.each do |report|
        output_data  = []
        output_data << (report.data['title'] || "*")
        output_data << (report.data['pi'] || "*")
        output_data << (report.data['researcher'] || "*")
        output_data << (report.data['analyst'] || "*")
        output_data << (report.meta['date'] || "*")
        output_data << (report.file_path || "*")

        self.results << output_data
      end
    end


    def print_results
      max_lengths = self.results[0].map {|r| 0}

      self.results.each do |r|
        r.each_with_index do |entry, i|
          size = entry.size
          max_lengths[i] = size if size > max_lengths[i]
        end
      end

      self.results.each do |result|
        format = max_lengths.map { |l| "%#{l}s" }.join(" " * 5)
        puts format % result
      end
    end

  end
end
