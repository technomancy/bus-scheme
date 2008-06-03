module BusScheme

  define 'defwebapp', primitive {|*args| Web::App.new(*args) }

  module Web
    class App
      def initialize(path, contents)
        raise "defwebapp needs to be called with a Lambda" unless contents.is_a? Lambda
        @contents = contents
        Resource[path] = self
        BusScheme::Web.serve
      end

      def call(env)
        status, headers, body = *@contents.call(BusScheme.cons(env))
        headers = Hash[*headers]
        # TODO: sanitize headers and status code
        [status, headers, body]
      end
    end
  end
end