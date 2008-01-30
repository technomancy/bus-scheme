module BusScheme
  class Cons
    attr_accessor :car, :cdr
    
    def initialize(car, cdr = nil)
      @car, @cdr = [car, cdr]
    end

    def ==(other)
      @car == other.car and @cdr == other.cdr
    end

    alias_method :first, :car
    alias_method :rest, :cdr

    def to_a
      if @cdr.respond_to? :to_a
        [@car] + @cdr.to_a
      elsif !@cdr.nil?
        [@car, @cdr]
      else
        [@car]
      end
    end

    def inspect(open = '(', close = ')')
      str = open + @car.inspect
      if @cdr.nil?
        str + close
      elsif @cdr.is_a? Cons
        str + ' ' + @cdr.inspect('', '') + close
      else
        str + ' . ' + @cdr.inspect + close
      end
    end
  end

  def cons(car, cdr = nil)
    Cons.new(car, cdr)
  end
end
