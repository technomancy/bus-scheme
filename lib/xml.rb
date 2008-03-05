require 'rubygems'
require 'builder'

module BusScheme
  special_form "xml", lambda { |args| Xml.create(args) }
  
  module Xml
    module_function
    def create(args, builder = Builder::XmlMarkup.new(:indent => 2))
      args = args.to_a # TODO: maybe keep them as lists?
      tag_name = args.shift
      attributes = extract_attributes(args)

      builder.method_missing(tag_name, attributes) do
        args.each do |arg|
          builder.text! arg if arg.is_a? String
          Xml::create(arg, builder) if arg.is_a? Cons or arg.is_a? Array
        end
      end
    end

    def extract_attributes(args)
      {}.affect do |attributes|
        while !args.empty? and  args.first.is_a?(Sym) do
          attributes[args.shift.to_sym] = args.shift
        end
      end
    end
  end

  class Cons
    def to_html
      Xml.create(self)
    end
  end
end
