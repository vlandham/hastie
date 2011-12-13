require 'thor/group'

module Hastie
  class ReportGenerator < Thor::Group
    include Thor::Actions

    desc "Creates framework for new report"
    argument :name, :type => :string, :desc => "The name of the new report"
    class_option :report_type, :default => :markdown

    def self.source_root
      File.dirname(__FILE__)
    end

    def create_test_file
      create_file "#{name}/#{name}_report.markdown"
    end
  end
end
