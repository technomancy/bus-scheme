require 'rubygems'
require 'rack'
require 'mongrel'

require 'bus_scheme'
require 'bus_scheme/xml'

module BusScheme
  define 'define-resource', primitive { |*args| Resource.new(*args) }
  
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
      [200, headers(env), representation(env)]
    end

    def headers(env)
      @@default_headers
    end

    def representation(env)
      # TODO: allow other representation formats
      @contents.to_html
    end

    def link(text)
      Xml.create [:a.sym, :href.sym, @path, text]
    end
    
    def self.not_found
      lambda { |e| [404, @@default_headers, "<h1>404 Not Found</h1>"] }
    end

    def self.[](path)
      @resources[path] or
        @resources.detect { |matcher, r|
        path =~ matcher if matcher.is_a? Regexp
      } or not_found
    end
    
    def self.[]=(path, resource)
      @resources[path] = resource
    end
  end
end
