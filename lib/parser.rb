module BusScheme
  INVALID_IDENTIFER_BEGIN = ('0' .. '9').to_a + ['+', '-', '.']
  
  module_function

  # Turn an input string into an S-expression
  def parse(input)
    @@lines = 1
    # TODO: should sexp it as it's being constructed, not after
    parse_tokens(tokenize(input).flatten).sexp
  end

  # Turn a list of tokens into a properly-nested array
  def parse_tokens(tokens)
    token = tokens.shift
    if token == :'('
      parse_list(tokens)
    else
      raise ParseError unless tokens.empty?
      token # atom
    end
  end
  
  # Nest a list from a 1-dimensional list of tokens
  def parse_list(tokens)
    list = [].affect do |list|
      while element = tokens.shift and element != :')'
        if element == :'('
          list << parse_list(tokens)
        else
          list << element
        end
      end
      raise IncompleteError unless element == :')'
    end
    parse_dots_into_cons list
  end

  # Parse a "dotted cons" (1 . 2) into (cons 1 2)
  def parse_dots_into_cons(list)
    if(list && list.length > 0 && list[1] == :'.')
      list = list.dup
      list.delete_at 1
      list.unshift(:cons.sym)
    end
    list
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
              #              when /\A#([^\)])/
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
            when /\A(-?\+?[0-9]*\.[0-9]+)/ # float
              Regexp.last_match[1].to_f
            when /\A(\.)/ # dot (for pair notation), comes after float to pick up any dots that float doesn't accept
              :'.'
            when /\A(-?[0-9]+)/ # integer
              Regexp.last_match[1].to_i
            when /\A("(.*?)")/m # string
              Regexp.last_match[2]
              # Official Scheme valid identifiers:
              # when /\A([A-Za-z!\$%&\*\.\/:<=>\?@\^_~][A-Za-z0-9!\$%&\*\+\-\.\/:<=>\?@\^_~]*)/ # symbol
              # when /\A([^-0-9\. \n\)][^ \n\)]*)/
            when /\A([^ \n\)]+)/ # symbols
              # puts "#{Regexp.last_match[1]} - #{@@lines}"
              # cannot begin with a character that may begin a number
              sym = Regexp.last_match[1].sym
              sym.file, sym.line = [BusScheme.loaded_files.last, @@lines]
              raise ParseError, "Invalid identifier: #{sym}" if INVALID_IDENTIFER_BEGIN.include? sym[0 .. 0] and sym.size > 1
              sym
            else
              raise ParseError if input =~ /[^\s ]/
            end

    # Remove the matched part from the string
    input[0 .. Regexp.last_match[1].length - 1] = '' if token
    return token
  end
end
