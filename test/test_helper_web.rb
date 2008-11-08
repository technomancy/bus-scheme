if defined? BusScheme::Web::Resource
  module BusScheme
    module_function
    def Web.server # need to expose this for MockRequest
      @server
    end
  end

  class Test::Unit::TestCase
    private

    def mock_request
      Rack::MockRequest.new(BusScheme::Web.server)
    end
    def get(path)
      @response = mock_request.get(path)
    end

    def put(path, contents)
      @response = mock_request.put(path, { :input => contents })
    end

    def post(path, contents)
      @response = mock_request.post(path, contents)
    end

    def delete(path)
      @response = mock_request.delete(path)
    end

    def assert_response(expected, message = nil)
      raise "No request has been made!" if @response.nil?
      # TODO: make this a little less picky about whitespace etc.
      assert_equal expected, @response.body, message
    end

    def assert_response_match(expected, message = nil)
      raise "No request has been made!" if @response.nil?
      assert_match expected, @response.body, message
    end

    def assert_response_code(expected, message = nil)
      raise "No request has been made!" if @response.nil?
      assert_equal expected, @response.status, message
    end
  end
end
