require 'rubygems'
require 'rack'
require 'mongrel'

require 'bus_scheme/xml'
require 'bus_scheme/web/client'
require 'bus_scheme/web/resource'
require 'bus_scheme/web/collection'
require 'bus_scheme/web/rack_app'

module BusScheme
  module Web
    def self.serve(port = 2000)
      # TODO: fallback to webrick if mongrel is not found
      @server ||= lambda { |env| Resource[env].call(env) }
      @thread ||= Thread.new { Rack::Handler::Mongrel.run @server, :Port => port }
    end
    
    def self.thread
      @thread
    end

    def self.redirect(to, headers = {})
      to = to.path if to.is_a? Resource
      [302, headers.merge({'location' => to}), '']
    end
  end
  
  define 'webwait', primitive { Web.thread.join }
  
end
