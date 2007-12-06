require 'array_extensions'

class Schemancy
  class << self
    def parse(string)
      if string =~ /^\((.*)\)$/
        [parse(Regexp.last_match[1]).shallow_flatten]
      elsif string =~ /(.*)(\(.+\))(.*)/
        match = Regexp.last_match
        (1 .. 3).map { |i| parse(match[i]) unless match[i].empty? }.compact
      elsif string.include?(' ')
        string.split(/ /).map{ |token| parse(token) }
      elsif string =~ /^\d+$/
        string.to_i
      elsif string =~ /^"(.*)"$/
        Regexp.last_match[1]
      elsif string.length > 0
        string.intern
      elsif string.empty?
        raise 'ParseError: empty string'
      end
    end

    def eval()
    end
  end
end
