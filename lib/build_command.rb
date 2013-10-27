require 'linguistics'
require 'orderedhash'

module Dropwizard
  class BuildCommand

    attr_reader :service_name
    attr_reader :model

    def initialize(args) 
      config = YAML.load_file("#{Dir.getwd}/config.yml")
      @service_name = config["service_name"]
      @model = config["model_name"]
    end

    def run
      system "mvn package"
    end
  end
end
