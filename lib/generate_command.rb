require 'artii'
require 'erb'
require 'linguistics'
require 'orderedhash'
require 'pathname' # 1.8
require 'uri_template'

module Dropwizard
  class GenerateCommand

    def self.input_types
        [ 'byte', 'short', 'int', 'long', 'float', 'double', 'boolean', 'string', 'date' ]
    end

    def self.types
      { 'byte'      => 'Byte',
        'short'     => 'Short',
        'int'       => 'Int', 
        'long'      => 'Long', 
        'float'     => 'Int', 
        'double'    => 'Long', 
        'boolean'   => 'Byte', 
        'String'    => 'Utf8String',
        'LocalDate' => 'Utf8String' 
      }
    end

    attr_reader :new_app
    attr_reader :action
    attr_reader :service_name
    attr_reader :model
    attr_reader :attrs
    attr_reader :idName
    attr_reader :idType
    attr_reader :resources
    attr_reader :new_resource

    def initialize(args) 
      raise "usage: dropwizard generate [resource | model] ..." if args.empty?
      @new_app = false

      config = YAML.load_file("#{Dir.getwd}/config.yml")
      @service_name = config["service_name"]
      @model = config["model_name"]
      @attrs = OrderedHash.new
      if config["attrs"]
        config["attrs"].each { |k, v| attrs[k] = v }
      end

      @action = args[0]
      case action
      when "model"
        parseArgs(args)
      when "resource"
        raise "usage: dropwizard generate resource NAME [GET | POST] URI_TEMPLATE [FORM_PARAM, ...]" if args.length < 4
        name = args[1] 
        method = args[2]
        path = args[3] 
        params = args[4].split(",") if args.length > 4
        @new_resource = Resource.new(name, method, path, params)
      end

      @resources = []
      if config["resources"]
        config["resources"].each do |x| 
          r = Resource.new(x["name"], x["method"], x["path"], x["params"])
          raise "Resource with name #{new_resource.name} already exists" if new_resource && new_resource.name == r.name 
          raise "Resource with path #{new_resource.path} already exists" if new_resource && new_resource.path == r.path 
          resources << r
        end 
      end

    end

    def parseArgs(args)
      if args[0] == "model"
        model_usage() if args.length < 3
        model = args[1]
        @model = model[0, 1].downcase + model[1..-1] if model
        @attrs = OrderedHash.new
        (2...args.length).each do |i| 
          name, type = args[i].split(":")
          model_usage() if ! GenerateCommand.input_types.include?(type)
          type.downcase!
          case type
          when "string"
            type = "String"
          when "date"
            type = "LocalDate"
          end
          @attrs[name] = type
          @idName = name if i == 2
          @idType = type if i == 2
        end
        @attrs.each_pair do |k, v|
          puts "Attr #{k}:#{v}"
        end
      end
    end

    def model_usage
      raise usage() + "\n" +
      "                where TYPE is one of #{GenerateCommand.input_types.join(', ')}"
    end

    def usage
      "usage: dropwizard generate model NAME ATTR:TYPE ..."
    end

    def model_plural
        Linguistics.use :en
        String.new(model).en.plural if model
    end

    def run
      if action == "resource"
        generate_resource
      else
        generate_all
      end
    end

    def generate_resource
      resource = new_resource
      resources << new_resource
      partie = ! model.nil?

      files = {
        "config.yml.erb"                   => "config.yml",
        "DropwizardService.java.erb"       => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/#{service_name.cap_first}Service.java",
        "DropwizardResource.java.erb"      => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/resources/#{new_resource.name.cap_first}Resource.java"
      }
      files.each { |key, value| generate(binding, key, value) }
    end

    def generate_all
      puts "Generating..."
      a = Artii::Base.new
      banner = a.asciify(service_name) 
      partie = ! model.nil?

      mkdir "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/#{model_plural}" if partie

      files = {
        "config.yml.erb"                   => "config.yml",
        "findbugs-exclude.xml.erb"         => "findbugs-exclude.xml",
        "parent-pom.xml.erb"               => "pom.xml",
        "README.md.erb"                    => "README.md",
        "api-pom.xml.erb"                  => "#{service_name}-api/pom.xml",
        "client-pom.xml.erb"               => "#{service_name}-client/pom.xml",
        "DropwizardClient.java.erb"        => "#{service_name}-client/src/main/java/com/yammer/#{service_name}/client/#{service_name.cap_first}Client.java",
        "service-pom.xml.erb"              => "#{service_name}-service/pom.xml",
        "dropwizard.yml.erb"               => "#{service_name}-service/#{service_name}.yml",
        "DropwizardConfiguration.java.erb" => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/#{service_name.cap_first}Configuration.java",
        "DropwizardService.java.erb"       => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/#{service_name.cap_first}Service.java",
        "banner.txt.erb"                   => "#{service_name}-service/src/main/resources/banner.txt",
      }
      files.each { |key, value| generate(binding, key, value) }

      if partie
        partie_files = {
          "partie_cluster.conf.erb"        => "#{service_name}-service/#{service_name}_cluster.conf",
          "JodaModule.java.erb"            => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/JodaModule.java",
          "PartieModel.java.erb"           => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/model/#{model.cap_first}.java",
          "PartieModelId.java.erb"         => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/model/#{model.cap_first}Id.java",
          "PartieResource.java.erb"        => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/resources/#{model.cap_first}Resource.java",
          "LocalDateParam.java.erb"        => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/resources/LocalDateParam.java",
          "PartieCodec.java.erb"           => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/serialization/#{model.cap_first}Codec.java",
          "PartieIdCodec.java.erb"         => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/serialization/#{model.cap_first}IdCodec.java",
          "PartieStore.java.erb"           => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/store/#{model.cap_first}Store.java",
          "PartieEditView.java.erb"        => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/views/#{model.cap_first}EditView.java",
          "PartieIndexView.java.erb"       => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/views/#{model.cap_first}IndexView.java",
          "PartieNewView.java.erb"         => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/views/#{model.cap_first}NewView.java",
          "PartieShowView.java.erb"        => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/views/#{model.cap_first}ShowView.java",
          "bootstrap.min.css"              => "#{service_name}-service/src/main/resources/assets/css/bootstrap.min.css",
          "datepicker.css"                 => "#{service_name}-service/src/main/resources/assets/css/datepicker.css",
          "glyphicons-halflings.png"       => "#{service_name}-service/src/main/resources/assets/img/glyphicons-halflings.png",
          "glyphicons-halflings-white.png" => "#{service_name}-service/src/main/resources/assets/img/glyphicons-halflings-white.png",
          "bootstrap.min.js"               => "#{service_name}-service/src/main/resources/assets/js/bootstrap.min.js",
          "bootstrap-datepicker.js"        => "#{service_name}-service/src/main/resources/assets/js/bootstrap-datepicker.js",
          "jquery-1.7.2.min.js"            => "#{service_name}-service/src/main/resources/assets/js/jquery-1.7.2.min.js",
          "header.ftl.erb"                 => "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/header.ftl",
          "footer.ftl.erb"                 => "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/footer.ftl",
          "partie-edit.ftl.erb"            => "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/#{model_plural}/edit.ftl",
          "partie-index.ftl.erb"           => "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/#{model_plural}/index.ftl",
          "partie-new.ftl.erb"             => "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/#{model_plural}/new.ftl",
          "partie-show.ftl.erb"            => "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/#{model_plural}/show.ftl",
        }
        partie_files.each { |key, value| generate(binding, key, value) }
      end
    end

    def generate(binding, source, target)
      if new_app 
        puts "create #{service_name}/#{target}"
      else
        puts "create #{target}"
      end
      this_dir = Pathname.new(File.dirname(__FILE__))
      template = ERB.new File.new("#{this_dir}/templates/#{source}").read
      code = template.result(binding)
      if new_app
        File.open("#{service_name}/#{target}", "w").write(code)
      else
        File.open("#{target}", "w").write(code)
      end
    end

    def mkdir(name)
      if ! File.exists?(name)
        puts "create #{name}"
        FileUtils::mkdir_p "#{name}"
      end
    end

  end

  class Resource
    attr_reader :name, :method, :path, :path_params, :params

    def initialize(name, method, path, params)
      @name = name
      @method = method.downcase
      @path = path
      @path_params = URITemplate.new(path).variables
      @params = if @method == "post" then params else [] end
    end
  end

end
