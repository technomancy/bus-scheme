require 'rubygems'

begin
  require 'rack'

  require 'bus_scheme/xml'
  require 'bus_scheme/web/client'
  require 'bus_scheme/web/resource'
  require 'bus_scheme/web/collection'
  require 'bus_scheme/web/rack_app'

  module BusScheme
    module Web
      begin
        require 'rack/handler/mongrel'
        Handler = Rack::Handler::Mongrel
      rescue ::LoadError # Maybe fall back to some others?
        require 'rack/handler/webrick'
        Handler = Rack::Handler::WEBrick # TODO: suppress stdout chatter
      end

      def self.serve(port = 2000)
        @server ||= lambda { |env| Resource[env].call(env) }
        @thread ||= Thread.new { Handler.run @server, :Port => port }
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
rescue LoadError
  warn "Rack gem not found; proceeding withuot web server features."
end
