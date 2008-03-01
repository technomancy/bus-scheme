module BusScheme
  class Cons
    attr_accessor :car, :cdr

    # TODO: figure out default values
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
      Cons.new(mapper.call(@car), @cdr ? @cdr.map(mapper) : @cdr)
    end

    def each(&block)
      yield @car
      @cdr.each(&block) if @cdr && @cdr.respond_to?(:each)
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

    def empty?
      @car.nil? && @cdr.nil?
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

    # allows for (mylist 4) => (nth mylist 4)
    def call(nth)
      nth == 0 ? @car : @cdr.call(nth - 1)
    end
    include Callable
  end

  def cons(car, cdr = nil)
    Cons.new(car, cdr)
  end
end
