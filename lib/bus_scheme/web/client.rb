require 'net/http'
require 'uri'

module BusScheme
  define('web-get', primitive do |uri, options|
           BusScheme['http-method'].call(['get', uri, options])[:body.sym]
         end)

  define('http-post', primitive do |uri, options|
           options ||= {}
           BusScheme['http-method'].call(['post', uri, options])
         end)

  # TODO: should we return a hash, or just the body? How do we offer
  # the necessary flexibility without making simple calls complicated?
  define('http-method', primitive do |method, uri, options|
           uri = URI.parse(uri)
           res = Net::HTTP.start(uri.host, uri.port) {|h|
             h.send(method, uri.path, options) }
           { :body.sym => res.body, :code.sym => res.code,
             :headers.sym => res.to_hash }
         end)
end
