require 'fileutils'
require 'hastie/constants'
require 'hastie/config_file'
require 'thor/group'
require 'grit'

module Hastie
  class ServerGenerator < Thor::Group
    include Thor::Actions
    desc "Creates framework for new server"
    argument :name, :type => :string, :desc => "The dir of the new server location. no spaces"

    def self.source_root
      File.dirname(__FILE__)
    end

    def set_destination
      # hack to unfreeze the options hash
      self.options = Thor::CoreExt::HashWithIndifferentAccess.new(options)

      # want to allow for relative paths
      options[:server_id] = File.basename(name)
      self.destination_root = File.join(File.dirname(name), options[:server_id])
      say_status "note", "root: #{self.destination_root}"
    end

    def create_server
      directory("templates/server", self.destination_root)
    end

    def create_git_repo
      in_root do
        say_status "note", "creating git repository in #{self.destination_root}"
        repo = Grit::Repo.init(".")
        all_files = Dir.glob("./**")
        #all_files.each {|f| say_status "note", "adding #{f}"}
        repo.add(all_files)
        repo.commit_all("initial commit of server scaffold. created from hastie")
      end
    end
  end
end
