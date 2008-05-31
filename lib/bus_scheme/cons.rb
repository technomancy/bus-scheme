module BusScheme
  class Cons
    attr_accessor :car, :cdr

    def initialize(car, cdr)
      @car, @cdr = [car, cdr]
    end

    def ==(other)
      other.respond_to?(:car) and @car == other.car and
        other.respond_to?(:cdr) and @cdr == other.cdr
    end

    alias_method :first, :car
    alias_method :rest, :cdr

    def length
      return 0 if @car.nil? and @cdr.nil?
      return 1 if @cdr.nil?
      return 2 if !@cdr.respond_to? :length
      1 + @cdr.length
    end

    alias_method :size, :length
    def last
      if @cdr.nil?
        @car
      elsif @cdr.is_a? Cons
        @cdr.last
      else
        @cdr
      end
    end
    
    def map(mapper = nil, &block)
      mapper ||= block
      Cons.new(mapper.call(@car), @cdr ? @cdr.map(mapper) : @cdr)
    end

    def each(&block)
      yield @car
      @cdr.each(&block) if @cdr && @cdr.respond_to?(:each)
    end
    
    def to_a(recursive = false)
      if @car.nil? && @cdr.nil?
        []
      elsif @cdr.respond_to? :to_a
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
      return open + close if @car.nil? and @cdr.nil?

      str = open + @car.inspect
      if @cdr.nil?
        str + close
      elsif @cdr.is_a? Cons
        str + ' ' + @cdr.inspect('', '') + close
      else
        str + ' . ' + @cdr.inspect + close
      end
    end

    def to_list
      self
    end

    # allows for (mylist 4) => (nth mylist 4)
    def call(nth)
      nth = nth.car if nth.is_a? Cons # TODO: remove?
      nth == 0 ? @car : @cdr.call(nth - 1)
    end
    include Callable
  end

  def cons(car = nil, cdr = nil)
    Cons.new(car, cdr)
  end
  module_function :cons
end
