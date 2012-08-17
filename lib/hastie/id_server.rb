require 'json'

module Hastie
  class IdServer
    attr_accessor :root_url, :domain
    def initialize url = "", domain = "cbio"
      self.root_url = url
      self.domain = domain
    end

    def request_id pi, researcher
      request = {"issuer" => domain, "lab" => pi, "sponsor" => researcher, "project" =>
        {"description" => "new project"}}.to_json
      command = "curl -H \"Accept: application/json\" -H \"Content-type: application/json\" -X POST -d"
      "#{self.domain}.tst.100 -d '#{request.to_s}' #{url}/projects"
      puts command
      "cbio.tst.1000"
    end
  end
end
