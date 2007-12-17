module BusScheme
  class << self
    # Turn an input string into an S-expression
    def parse(input)
      parse_tokens tokenize(normalize_whitespace(input))
    end

    # Turn a list of tokens into a properly-nested S-expression
    def parse_tokens(tokens)
      token = tokens.shift
      if token == :'('
        parse_list(tokens)
      else
        raise BusScheme::ParseError unless tokens.empty?
        token # atom
      end
    end

    # Nest a list from a 1-dimensional list of tokens
    def parse_list(tokens)
      [].affect do |list|
        while element = tokens.shift and element != :')'
          if element == :'('
            list << parse_list(tokens)
          else
            list << element
          end
        end
      end
    end

    # Split an input string into lexically valid tokens
    def tokenize(input)
      [].affect do |tokens|
        while token = pop_token(input)
          tokens << token
        end
      end
    end

    # Take a token off the input string and return it
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

    # Treat all whitespace in a string as spaces
    def normalize_whitespace(string)
      string && string.gsub(/\t/, ' ').gsub(/\n/, ' ').gsub(/ +/, ' ')
    end
  end
end
