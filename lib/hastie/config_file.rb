require 'yaml'
require 'thor/core_ext/hash_with_indifferent_access'

module Hastie
  class ConfigFile

    # takes yaml filename
    # outputs thor's hash with indifferent access of content
    # if input file cannot be read, empty thor hash is returned
    def self.load filename, root = nil
      if !File.exists? filename
        return
      end
      output = Thor::CoreExt::HashWithIndifferentAccess.new()
      config = YAML.load(File.read(filename))
      if config
        if root
          config = {root => config}
        end
        output = Thor::CoreExt::HashWithIndifferentAccess.new(config)
      end
      output
    end

    def self.write filename, data
      output_data = data.to_hash.to_yaml
      File.open(filename, 'w') {|file| file.puts output_data}
    end

    # very lazy. very limited
    # only use for _reports.yml
    def self.append filename, data
      if !File.exists? filename
        puts "ERROR: #{filename} not found"
        return
      end
      File.open(filename, 'a') do |file|
        file.puts "- #{data}"
      end
    end
  end
end
