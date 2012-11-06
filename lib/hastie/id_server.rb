require 'json'

module Hastie
  class IdServer
    attr_accessor :root_url, :domain
    def initialize url = "", domain = "cbio"
      self.root_url = url
      self.domain = domain
    end

    def create_request pi, researcher, options = {}
      request = {"issuer" => domain, "lab" => pi, "sponsor" => researcher}
      request["project"] = {"description" => "new project", "status" => "new"}
      if options[:analyst]
        request["project"]["lead"] = options[:analyst]
      end
      request.to_json
    end

    def request_id pi, researcher, options = {}
      request = create_request(pi, researcher, options)
      command = "curl --silent -H \"Accept: application/json\" -H \"Content-type: application/json\" -X POST -d '#{request.to_s}' #{self.root_url}/projects"
      # "#{self.domain}.tst.100 -d '#{request.to_s}' #{url}/projects"
      # puts command
      response = `#{command}`
      # puts response
      JSON.parse(response)
    end
  end
end
