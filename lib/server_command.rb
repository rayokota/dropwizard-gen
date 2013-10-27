require 'linguistics'
require 'orderedhash'

module Dropwizard
  class ServerCommand

    attr_reader :service_name
    attr_reader :model

    def initialize(args) 
      config = YAML.load_file("#{Dir.getwd}/config.yml")
      @service_name = config["service_name"]
      @model = config["model_name"]
    end

    def run
      system "cd #{service_name}-service; java -jar target/#{service_name}-service-0.0.1-SNAPSHOT.jar server #{service_name}.yml"
    end
  end
end
