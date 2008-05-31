require 'rubygems'
require 'builder'

module BusScheme
  special_form "xml", primitive { |args| Xml.create(args) }
  
  module Xml
    module_function
    def create(args, builder = Builder::XmlMarkup.new(:indent => 2))
      tag_name, args = args.car, args.cdr
      attributes = extract_attributes(args)
      attributes.size.times { args = args.cdr.cdr || []}
      
      # puts "Sending #{tag_name} with args #{args.inspect}"
      builder.method_missing(tag_name, attributes) do
        args.each do |arg|
          builder.text! arg if arg.is_a? String
          Xml::create(arg, builder) if arg.is_a? Cons or arg.is_a? Array
        end
      end
    end

    def extract_attributes(args, attributes = {})
      if args.nil? or args.empty? or !args.car.is_a? Sym
        attributes
      else
        extract_attributes(args.cdr.cdr,
                           attributes.merge(args.car => args.cdr.car))
      end
    end
  end

  class Cons
    def to_html
      Xml.create(self)
    end
  end
end
