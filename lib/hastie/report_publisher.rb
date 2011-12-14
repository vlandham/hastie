require 'fileutils'
require 'hastie/config_file'
require 'hastie/constants'
require 'hastie/server_reader'

module Hastie
  class ReportPublisher < ServerReader
    desc "Publishes report to server"

    def setup_variables
      puts options.inspect
    end
  end
end
