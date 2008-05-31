module BusScheme
  INVALID_IDENTIFER_BEGIN = ('0' .. '9').to_a + ['+', '-', '.']
  CHARACTER_LITERALS = {
    # All single characters are assumed (eg: #\a -> 'a')
    "space" => ' ',
    "sp" => ' ',
    "newline" => "\n",
    "nl" => "\n" ,
    "tab" => "\t" ,
    "ht" => "\t"
  }
  
  module_function

  # Turn an input string into an S-expression
  def parse(input)
    @@lines = 1
    parse_tokens(tokenize(input).flatten)
  end

  # Turn a list of tokens into a properly-nested array
  def parse_tokens(tokens)
    # TODO: hacky; let's be smarter about this
    return cons if tokens == [:'(', :')']
    token = tokens.shift
    if token == :'(' 
      parse_dots_into_cons(parse_list(tokens))
    else
      raise ParseError unless tokens.empty?
      token # atom
    end
  end
  
  # Nest a list from a 1-dimensional list of tokens
  def parse_list(tokens, level = 0)
    # puts ' ' * level + tokens.inspect
    raise IncompleteError if tokens.empty?
    element = tokens.shift

    if element == :'('
      car = parse_list(tokens, level + 2) || cons
      cdr = parse_list(tokens, level + 2)
      
      cons(car, cdr)
    elsif element == :')'
      return
    else
      cons(element, parse_list(tokens, level + 2))
    end
  end

  # Parse a "dotted cons" (1 . 2) into (cons 1 2)
  def parse_dots_into_cons(list)
    if(list && list.length > 2 && list.cdr.car == :'.')
      cons(:cons.sym, cons(list.car, cons(list.cdr.cdr.car)))
    elsif list.car.nil?
      cons(cons, list.cdr)
    else
      list
    end
  end

#   # Try each key in CHARACTER_LITERALS, if no matches, assume single
#   # character literal.
#   def parse_character_literal(input, char)
#     CHARACTER_LITERALS.each_key do |key|
#       if input =~ Regexp.new("^#{key}")
#         input.shift key.length
#         return CHARACTER_LITERALS[key]
#       end
#     end
#     return char
#   end

  def parse_character_literal(input, char)
    # try each key in CHARACTER_LITERALS, if no matches, assume single
    # character literal
    found = false
    CHARACTER_LITERALS.each_key do |key|
      if input[0 ... key.length] == key
        found = true
        char = CHARACTER_LITERALS[key]
        input.shift key.length
      end
    end
    input.shift unless found
    return char
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
              input.shift 2
              return [:'(', :vector.sym, tokenize(input)]
            when /\A'/ # single-quote
              input.shift
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
            when /\A#\\(.)/ # Character literal
              char = Regexp.last_match[1]
              input.shift 2
              return parse_character_literal(input, char)
            when /\A(\/(.*?)\/)/m # Regex
              Regexp.new(Regexp.escape(Regexp.last_match[2]))
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
