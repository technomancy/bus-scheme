class Schemancy
  class << self
    def parse(string)
      if string =~ /^\((.*)\)$/
        [parse(Regexp.last_match[1])]
      elsif string.include?(' ')
        string.split(' ').map{ |token| parse(token) }
      elsif string =~ /^\d+$/
        string.to_i
      elsif string =~ /^"(.*)"$/
        Regexp.last_match[1]
      else
        string.intern
      end
    end

    def eval()
    end
  end
end
