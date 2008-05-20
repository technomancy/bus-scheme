require 'rubygems'
require 'rack'
require 'mongrel'

require 'bus_scheme'
require 'bus_scheme/xml'

module BusScheme
  define 'define-resource', primitive {|*args| Web::Resource.new(*args)}

  module Web
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
        BusScheme::Web.serve # imdepotent
      end

      def call(env)
        begin
          [200, headers(env), representation(env)]
        rescue => e
          [500, @@default_headers, "<h1>Application Error</h1>
<h4>#{e.message}</h4>
<pre>#{e.backtrace.join("\n")}</pre>"]
        end
      end

      def headers(env)
        @@default_headers
      end

      def representation(env)
        if @contents.is_a? Lambda
          @contents.call(env).to_html
        else
          @contents.to_html
        end
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
end
