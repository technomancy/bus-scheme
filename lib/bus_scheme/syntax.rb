module BusScheme
  # Mwahahah
  special_form 'define-syntax', primitive { |keyword, transformer|
    BusScheme::SYMBOL_TABLE[keyword.sym] = eval(transformer); keyword.sym }

  special_form 'syntax-rules', primitive { |literals, *rules|
    Transformer.new(literals, rules) }

  class Transformer
    def initialize(literals, rules)
      @rules = rules
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
      # puts "Matching #{rule.inspect} with #{body.inspect}..."
      if rule.null? and body.null?
        true
      elsif rule.is_a?(Sym) and !body.is_a?(Cons)
        true
      elsif rule == '...'.sym or rule == Cons.new('...'.sym, nil)
        # TODO: checking for both above doesn't feel right.
        true
      elsif rule.null? or body.null?
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
