$LOAD_PATH << File.dirname(__FILE__)
require 'object_extensions'
require 'array_extensions'
require 'readline'

module BusScheme
  class ParseError < StandardError; end

    PRIMITIVES = {
      :add1 => lambda { |x| x + 1 },
      :sub1 => lambda { |x| x - 1 },
      :define => lambda { |sym, definition| SYMBOL_TABLE[sym] = BusScheme.eval(definition) },
      :quote => lambda { |*form| form },

      :+ => lambda { |x, y| x + y },
      :- => lambda { |x, y| x - y },
      :'/' => lambda { |x, y| x / y },
      :* => lambda { |x, y| x * y },
      :intern => lambda { |x| x.intern },
      :concat => lambda { |x, y| x + y },
      :substring => lambda { |x, from, to| x[from .. to] }
    }

    SYMBOL_TABLE = {}.merge(PRIMITIVES)

  class << self
    def eval(form)
      form = parse(form) if form.is_a? String
      if form == []
        nil
      elsif form.is_a? Array
        apply(form.first, form.rest)
      else
        form
      end
    end

    def apply(function, args)
      SYMBOL_TABLE[function].call(*args)
    end

    def parse(input)
      parse_tokens tokenize(normalize_whitespace(input))
    end

    def parse_tokens(tokens)
      token = tokens.shift
      if token == :'('
        parse_list(tokens)
      elsif tokens.empty?
        token # atom
      else
        raise BusScheme::ParseError
      end
    end

    def parse_list(tokens)
      [].returning do |list|
        while element = tokens.shift and element != :')'
          if element == :'('
            list << parse_list(tokens)
          else
            list << element
          end
        end
      end
    end

    def tokenize(input)
      [].returning do |tokens|
        while token = pop_token(input)
          tokens << token
        end
      end
    end

    def pop_token(input)
      token = case input
              when /^ +/ # whitespace
                input[0 ... 1] = ''
                return pop_token(input)
              when /^\(/ # open paren
                :'('
              when /^\)/ # closing paren
                :')'
              when /^(\d+)/ # positive integer
                Regexp.last_match[1].to_i
              when /^"(.*?)"/ # string
                Regexp.last_match[1]
              when /^([^ \)]+)/ # symbol
                Regexp.last_match[1].intern
              end
      # compensate for quotation marks
      length = token.is_a?(String) ? token.length + 2 : token.to_s.length
      input[0 .. length - 1] = ''
      return token
    end

    def normalize_whitespace(string)
      string && string.gsub(/\t/, ' ').gsub(/\n/, ' ').gsub(/ +/, ' ')
    end
  end
end

# REPL-tastic
loop { print "> "; puts BusScheme.eval(Readline.readline) } if $0 == __FILE__
