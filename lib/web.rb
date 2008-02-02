require 'rubygems'
require 'mongrel'

# try evaling:
# (http-listen (lambda (req) "hello world"))
# and then curl http://localhost:3500

module BusScheme
  SYMBOL_TABLE[:'http-listen'] = lambda do |*args|
    handler_function = args[0]
    path = args[1] || '/'
    host = args[2] || 'localhost'
    port = args[3] || 3500

    Mongrel::Configurator.new :host => host do
      listener :port => port do
        http_handler = Mongrel::HttpHandler.new

        process = lambda do |request, response|
          response.start(200) do |head, out|
            head['Content-Type'] = 'text/html'
            out.write(handler_function.call(request))
          end
        end

        http_handler.extend(Module.new{ define_method(:process, process) })

        uri(path, :handler => http_handler)
      end

      run
    end
  end
end
