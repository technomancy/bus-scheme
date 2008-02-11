module BusScheme
  class << self
    IDENTIFIER_CHARS = "[^ \n\)]"
#    IDENTIFIER_CHARS = "A-Za-z0-9!\\$%&\\*\\+\\-\\.\\/:<=>\\?@\\^_~"
    IDENTIFIER_BEGIN = IDENTIFIER_CHARS #.gsub("(\\+\\-|0-9|\\.)", "")

    # Turn an input string into an S-expression
    def parse(input)
      @@lines = 0
      # TODO: should sexp it as it's being constructed, not after
      parse_tokens(tokenize(input).flatten).sexp
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
        raise ParseError unless element == :')'
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
      # can't use ^ since it matches line beginnings in mid-string
      token = case input
              when /\A(\s|;.*$)/ # ignore whitespace and comments
                @@lines += Regexp.last_match[1].count("\n")
                input[0 .. Regexp.last_match[1].length - 1] = ''
                return pop_token(input)
              when /\A(\(|\))/ # parens
                Regexp.last_match[1].intern
              when /\A#\(/ # vector
                input[0 ... 2] = ''
                return [:'(', :vector.sym, tokenize(input)]
              when /\A'/ # single-quote
                input[0 ... 1] = ''
                return [:'(', :quote.sym,
                        if input[0 ... 1] == '('
                          tokenize(input)
                        else
                          pop_token(input)
                        end,
                        :')']
              when /\A(-?[0-9]*\.[0-9]+)/ # float
                Regexp.last_match[1].to_f
              when /\A(-?[0-9]+)/ # integer
                Regexp.last_match[1].to_i
              when /\A("(.*?)")/ # string
                Regexp.last_match[2]
              when /\A(#{IDENTIFIER_BEGIN}+#{IDENTIFIER_CHARS}*)/ # symbol
                # puts "#{Regexp.last_match[1]} - #{@@lines}"
                Regexp.last_match[1].sym.affect{ |sym| sym.file, sym.line = [BusScheme.loaded_files.last, @@lines] }
              end

      # Remove the matched part from the string
      input[0 .. Regexp.last_match[1].length - 1] = '' if token
      return token
    end
  end
end
