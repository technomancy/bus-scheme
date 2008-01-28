module BusScheme
  class Cons
    attr_accessor :car, :cdr
    
    def initialize(car, cdr)
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
  end

  def cons(car, cdr)
    Cons.new(car, cdr)
  end
end
