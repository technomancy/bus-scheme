module BusScheme
  define 'defresource', primitive {|*args| Web::Resource.new(*args) }
  define 'resources-list', primitive { BusScheme['resources'].values.to_list }
  module Web
    class Forbidden < BusSchemeError; end

    # TODO: way more of this stuff belongs in Scheme
    class Resource
      attr_reader :path, :contents
      @@default_headers = {'Content-Type' => 'text/html'}
      BusScheme['resources'] = {}
      
      def initialize(path, contents)
        @path, @contents = [path, contents]
        Resource[path] = self
        BusScheme::Web.serve # imdepotent
      end

      def call(env)
        @env = env # Hrm; this doesn't get cleared after requests. problem?
        begin
          raise Forbidden if not authorized?
          send(env['REQUEST_METHOD'].downcase)
        rescue Forbidden => e
          [401, @@default_headers, '<h1>Forbidden</h1>']
        rescue => e
          [500, @@default_headers, "<h1>Application Error</h1>
<h4>#{e.message}</h4>
<pre>#{e.backtrace.join("\n")}</pre>"]
        end
      end

      # TODO: implement somehow
      def authorized?; true; end

      def get
        [200, headers, representation]
      end

      def post
      end

      def delete
        Resource[@path] = nil
        Web.redirect('/')
      end

      def headers
        # TODO: Uh, yeah.
        @@default_headers
      end

      def representation
        if @contents.is_a? Lambda
          @contents.call(BusScheme.cons(@env)).to_html
        else
          @contents.to_html
        end
      end

      def link(text)
        Xml.create [:a.sym, :href.sym, @path, text]
      end

      def inspect
        "<Resource at \"#{@path}\">"
      end
      
      def self.not_found_handler
        lambda { |e| [404, @@default_headers, "<h1>404 Not Found</h1>"] }
      end

      def self.[](env)
        path = env['PATH_INFO']
        # PUT doesn't require target to exist
        if env['REQUEST_METHOD'] == 'PUT'
          lambda { |env| Resource.put(env) }
        else
          BusScheme['resources'][path] or not_found_handler
        end
      end
      
      def self.[]=(path, resource)
        BusScheme['resources'][path] = resource
      end

      def self.put(env)
        new_resource = !! Resource[env['PATH_INFO']]
        # Accepts an S-expression
        r = Resource.new(env['PATH_INFO'],
                         BusScheme.parse(env['rack.input'].read))
        [(new_resource ? 201 : 200),
         r.headers, r.representation]
      end
    end
  end
end
