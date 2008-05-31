module BusScheme
  # Mwahahah
  special_form 'define-syntax', primitive do |name, transformer|
  end

  special_form 'syntax-rules', primitive { |rules| SyntaxRule.new(rules) }

  class SyntaxRule
    def initialize(*rules)
      @rules = rules.to_list(true)
    end
  end
end
