module BusScheme
  # Mwahahah
  special_form 'define-syntax', primitive { |keyword, transformer|
    BusScheme::SYMBOL_TABLE[keyword.sym] =
      BusScheme['syntax-rules'.sym].call([transformer])
  }

  special_form 'syntax-rules', primitive { |rules| SyntaxRules.new(rules) }

  class SyntaxRules
    def initialize(rules)
      @rules = rules.cdr.cdr
    end

    def call(body)
      BusScheme.eval(transform(body))
    end

    def find_matching_rule(rules, body)
      raise "No matching #{@called_as} rule: #{body.inspect}" if rules.empty?
      rule = rules.car
      if matches?(rule.car.cdr, body)
        rule.cadr
      else
        find_matching_rule(rules.cdr, body)
      end
    end

    def matches?(rule, body)
      if rule.empty? and body.empty?
        true
      elsif rule.is_a?(Sym) and !body.is_a?(Cons)
        true
      elsif rule.empty? or body.empty?
        false
      elsif rule.is_a?(Cons) and body.is_a?(Cons)
        matches?(rule.car, body.car) and
          matches?(rule.cdr, body.cdr)
      end
    end

    def transform(body)
      rule = find_matching_rule(@rules, body)
      # TODO: perform transformation
    end

    def call_as(called_as, *args)
      @called_as = called_as
      call(*args)
    end

    # Yeah, that's kind of the whole point.
    def special_form; true end
  end
end
