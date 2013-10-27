require 'artii'
require 'erb'
require 'generate_command'
require 'linguistics'
require 'orderedhash'
require 'pathname' # 1.8

module Dropwizard
  class NewCommand < Dropwizard::GenerateCommand

    def initialize(args) 
      raise "usage: dropwizard new APP" if args.empty?
      @new_app = true
      service_name = args[0]
      @service_name = service_name[0, 1].downcase + service_name[1..-1]
      args.shift
      parseArgs(args)
      @resources = []
      mkdirs
    end

    def usage
      "usage: dropwizard new APP model NAME ATTR:TYPE ..."
    end

    def mkdirs
      mkdir "#{service_name}/#{service_name}-api"
      mkdir "#{service_name}/#{service_name}-client/src/main/java/com/yammer/#{service_name}/client"
      mkdir "#{service_name}/#{service_name}-service/src/main/java/com/yammer/#{service_name}/service"
      mkdir "#{service_name}/#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/model"
      mkdir "#{service_name}/#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/resources"
      mkdir "#{service_name}/#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/serialization"
      mkdir "#{service_name}/#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/store"
      mkdir "#{service_name}/#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/views"
      mkdir "#{service_name}/#{service_name}-service/src/main/resources"
      mkdir "#{service_name}/#{service_name}-service/src/main/resources/assets/css"
      mkdir "#{service_name}/#{service_name}-service/src/main/resources/assets/img"
      mkdir "#{service_name}/#{service_name}-service/src/main/resources/assets/js"
    end

  end
end
