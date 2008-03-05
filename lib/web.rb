require 'bus_scheme'
require 'rubygems'
require 'rack'
require 'yaml'
require 'xml'

module BusScheme
  define 'resource', lambda { |*args| Resource.new(*args) }

  module_function
  def serve(port = 2000)
    # TODO: fallback to webrick if mongrel is not found
    @web_server ||= lambda { |env| Resource[env['PATH_INFO']].call(env) }
    @web_thread ||= Thread.new { Rack::Handler::Mongrel.run @web_server, :Port => port }
  end

  class Resource
    attr_reader :path, :contents
    @@default_headers = {'Content-Type' => 'text/html'}
    @resources = {}
    
    def initialize(path, contents)
      @path, @contents = [path, contents]
      Resource[path] = self
      BusScheme.serve # imdepotent
    end

    def call(env)
      @env = env
      [200, headers, representation].affect { @env = nil }
    end

    def headers
      @@default_headers
    end

    def representation
      # TODO: allow other representation formats
      @contents.to_html
    end
    
    def self.not_found
      lambda { |e| [404, @@default_headers, "<h1>404 Not Found</h1>"] }
    end

    def self.[](path)
      if path.is_a? String
        @resources[path] || not_found
      elsif path.is_a? Regexp
        @resources.values_at(*@resources.keys.grep(path))
      end
    end
    
    def self.[]=(path, resource)
      @resources[path] = resource
    end
  end

  define 'collection', lambda { |*args| Collection.new(*args) }

  class Collection < Resource
    def representation
      Xml.create Cons.new(:ul.sym,
                          @contents.to_a.map{ |c| Cons.new(:li.sym,
                                                           Cons.new(c)) })
    end
  end
end
