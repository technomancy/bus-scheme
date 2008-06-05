module BusScheme
  # Mwahahah
  define 'define-syntax', primitive do |keyword, transformer|
    BusScheme[keyword] = SyntaxRule.new(transformer)
  end

  special_form 'syntax-rules', primitive { |rules| SyntaxRule.new(rules) }

  class SyntaxRule
    def initialize(*rules)
      @rules = rules.to_list(true)
    end

    def call(body)
    end

    # Yeah, that's kind of the whole point.
    def special_form; true end
  end
end
