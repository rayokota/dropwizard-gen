require 'curl'
require 'linguistics'
require 'orderedhash'
require 'uri'
require 'yaml'

module Dropwizard
  class ModelCommand

    attr_reader :action
    attr_reader :networkId
    attr_reader :objectId

    attr_reader :service_name
    attr_reader :model
    attr_reader :model_plural
    attr_reader :attrs

    def initialize(args) 
      raise "usage: dropwizard model [add | get | list | delete] ..." if args.empty?
      @action = args[0]
      case action
      when "add"
        raise "usage: dropwizard model add NETWORK_ID" if args.length < 2
        @networkId = args[1]
      when "get"
        raise "usage: dropwizard model get NETWORK_ID OBJECT_ID" if args.length < 3
        @networkId = args[1]
        @objectId = args[2]
      when "list"
        raise "usage: dropwizard model list NETWORK_ID" if args.length < 2
        @networkId = args[1]
      when "delete"
        raise "usage: dropwizard model delete NETWORK_ID OBJECT_ID" if args.length < 3
        @networkId = args[1]
        @objectId = args[2]
      else 
        raise "usage: dropwizard model [add | get | list | delete] ..."
      end
      config = YAML.load_file("#{Dir.getwd}/config.yml")
      @service_name = config["service_name"]
      @model = config["model_name"]
      @attrs = OrderedHash.new
      config["attrs"].each { |k, v| attrs[k] = v }
    end

    def model_plural
        Linguistics.use :en
        String.new(model).en.plural if model
    end

    def run
      send action.to_sym
    end

    def add
      Linguistics.use :en
      values = OrderedHash.new 
      attrs.each_key do |k| 
        print "Enter #{String.new(k).en.camel_case_to_english}: "
        values[k] = STDIN.gets.chomp
      end
      json = "{"
      json += attrs.map { |k, v| "\"#{k}\": \"#{values[k]}\"" }.join(", ")
      json += "}"
      c = Curl::Easy.http_post("http://127.0.0.1:8080/networks/#{networkId}/#{model_plural}", json) do |curl|
        #curl.verbose = true
        curl.headers['Accept'] = 'application/json'
        curl.headers['Content-Type'] = 'application/json'
      end
      puts "HTTP Response: #{c.response_code}"
      puts c.body_str
    end

    def get
      c = Curl::Easy.http_get("http://127.0.0.1:8080/networks/#{networkId}/#{model_plural}/#{URI.escape(objectId)}") do |curl|
        #curl.verbose = true
        curl.headers['Accept'] = 'application/json'
      end
      puts "HTTP Response: #{c.response_code}"
      puts c.body_str
    end

    def list
      c = Curl::Easy.http_get("http://127.0.0.1:8080/networks/#{networkId}/#{model_plural}") do |curl|
        #curl.verbose = true
        curl.headers['Accept'] = 'application/json'
      end
      puts "HTTP Response: #{c.response_code}"
      puts c.body_str
    end

    def delete
      c = Curl::Easy.http_delete("http://127.0.0.1:8080/networks/#{networkId}/#{model_plural}/#{URI.escape(objectId)}") do |curl|
        #curl.verbose = true
      end
      puts "HTTP Response: #{c.response_code}"
    end
  end
end
