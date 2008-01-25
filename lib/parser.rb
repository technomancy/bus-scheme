module BusScheme
  class << self
    # Turn an input string into an S-expression
    def parse(input)
      parse_tokens tokenize(input)
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
      # problem! in most cases, we want to only examine the first
      # line; otherwise the ^ metachar doesn't work as expected. but
      # to handle comments and parse out newlines, we can't just
      # examine the first line. freaking comments!
      
      token = case input
              when /^(\s)/ # whitespace
                input[0 ... 1] = ''
                return pop_token(input)
              when /^(\()/ # open paren
                :'('
              when /^(\))/ # closing paren
                :')'
              when /^([0-9]+)/ # positive integer
                Regexp.last_match[1].to_i
              when /^("(.*?)")/ # string
                Regexp.last_match[2]
              when /^([^ \)]+)/ # symbol
                Regexp.last_match[1].intern
              end
      # compensate for quotation marks
      input[0 .. Regexp.last_match[1].length - 1] = '' if token
      return token
    end
  end
end
