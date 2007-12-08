require 'object_extensions'
require 'yaml'

class BusScheme
  class ParseError < StandardError; end

  class << self
    def parse(input)
      parse_tokens tokenize(normalize_whitespace(input))
    end

    def parse_tokens(tokens)
      token = tokens.shift
      if token == :'('
        parse_list(tokens)
      elsif tokens.empty?
        token
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

    def parse_atom(tokens)
      tokens.first
    end

    def tokenize(input)
      tokens = []
      while token = pop_token(input)
        tokens << token
      end
      return tokens
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
              when /^"(.*)"/ # string
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
