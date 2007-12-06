require 'array_extensions'

class Schemancy
  class << self
    def parse(string)
      string = normalize_whitespace(string)
      case string
      when /^\(.*$/ # open paren
        [parse(string[1 .. -1])]
      when /^\)/ # close paren
        return
       when /^ .*$/
         parse string[1 .. -1]
      when /^\d+$/ # number
        string.to_i
      when /^"[^"]*"$/ # string
        string[1 .. -2]
      when /^([^ \)]+) (.+)/ # token followed by more
        token, rest = Regexp.last_match[1 .. 2]
        [parse(token)].cons(parse(rest))
      when /^([^ \)]+)\)/ # token at the end of a list
        token, rest = Regexp.last_match[1 .. 2]
        [parse(token)]
      else
        string.intern
      end
    end

    def normalize_whitespace(string)
      string && string.gsub(/\t/, ' ').gsub(/\n/, ' ').gsub(/ +/, ' ')
    end
  end
end
