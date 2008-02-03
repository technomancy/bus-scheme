require 'rubygems'
require 'mongrel'

module BusScheme
  HTTP_SERVERS = {}
  
  SYMBOL_TABLE[:'http-listen'] = lambda do |*args|
    handler_function = args[0]
    path = args[1] || '/'
    host = args[2] || '0.0.0.0'
    port = args[3] || 3500

    # has to be a closure so we have access to handler_function
    handler_method = lambda do |request, response|
      response.start(200) do |head, out|
        head['Content-Type'] = 'text/html'
        out.write(handler_function.call(request))
      end
    end

    mongrel_handler = Mongrel::HttpHandler.new
    mongrel_handler.extend(Module.new{ define_method(:process, handler_method) })

    server = (HTTP_SERVERS["#{host}:#{port}"] ||= Mongrel::HttpServer.new(host, port))
    server.register(path, mongrel_handler)
    server.run
  end
end
