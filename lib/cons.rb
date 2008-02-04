module BusScheme
  class Cons
    attr_accessor :car, :cdr
    
    def initialize(car, cdr = nil)
      @car, @cdr = [car, cdr]
    end

    def ==(other)
      other.respond_to?(:car) and @car == other.car and
        other.respond_to?(:cdr) and @cdr == other.cdr
    end

    alias_method :first, :car
    alias_method :rest, :cdr

    def map(mapper)
      cons(mapper.call(@car), @cdr ? @cdr.map(mapper) : @cdr)
    end
    
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
