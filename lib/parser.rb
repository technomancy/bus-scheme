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
      # REFACTOR
      if (input =~ /^(\s)/) == 0 # whitespace
        input[0 ... 1] = ''
        return pop_token(input)
      elsif (input =~ /^(;.*)$/) == 0 # comment
        input[0 .. Regexp.last_match[1].length - 1] = ''
        return pop_token(input)
      elsif (input =~ /^(\()/) == 0 # open paren
        token = :'('
      elsif (input =~ /^(\))/) == 0 # closing paren
        token = :')'
      elsif (input =~ /^([0-9]+)/) == 0 # positive integer
        token = Regexp.last_match[1].to_i
      elsif (input =~ /^("(.*?)")/) == 0 # string
        token = Regexp.last_match[2]
      elsif (input =~  /^([^ \n\)]+)/) == 0 # symbol
        token = Regexp.last_match[1].intern
      end

      # Remove the matched part from the string
      input[0 .. Regexp.last_match[1].length - 1] = '' if token
      return token
    end
  end
end
