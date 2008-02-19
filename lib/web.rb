require 'rubygems'
require 'mongrel'

# TODO: this should be rewritten as a Rack adapter.

module BusScheme
  module HTTP
    HTTP_SERVERS = {}
    SYMBOL_TABLE[:'http-listen'.sym] = lambda do |*args|
      handler_function = args[0]
      path = args[1] || '/'
      host = args[2] || '0.0.0.0'
      port = args[3] || 3500

      server = (HTTP_SERVERS["#{host}:#{port}"] ||= Mongrel::HttpServer.new(host, port))
      server.register(path, BusScheme::HTTP.mongrel_handler(handler_function))
      server.run
    end

    def self.mongrel_handler(function)
      Mongrel::HttpHandler.new.affect do |handler|
        handler.extend(Module.new{ define_method(:process, lambda do |request, response|
                                                   response.start(200) do |head, out|
                                                     head['Content-Type'] = 'text/html'
                                                     out.write(function.call(request))
                                                   end
                                                 end)})
      end
    end
  end
end
