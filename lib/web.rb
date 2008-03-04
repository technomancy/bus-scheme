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
    @server ||= lambda { |env| Resource[env['PATH_INFO']].call(env) }
    @web_thread ||= Thread.new { Rack::Handler::Mongrel.run @server, :Port => port }
  end

  class Resource
    attr_reader :path, :contents
    @@default_headers = {'Content-Type' => 'text/html'}
    
    def initialize(path, contents)
      @path, @contents = [path, contents]
      Resource.resources[path] = self
      BusScheme.serve # imdepotent; can call multiple times without effect
    end

    def call(env)
      @env = env
      [200, headers, representation]
      @env = nil
    end

    def headers
      @@default_headers
    end

    def representation
      @contents.to_html
    end
    
    def self.not_found
      lambda { |e| [404, @@default_headers, "<h1>404 Not Found</h1>"] }
    end

    def self.resources
      (@resources ||= {})
    end
  end

  class Collection < Resource
  end
end