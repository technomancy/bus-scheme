module BusScheme
  class StackFrame < Hash
    attr_reader :called_as, :file, :line, :called_from
    
    # takes a hash and a parent
    def initialize(locals, parent, called_as)
      @parent, @called_as = [parent, called_as]
      @file = @called_as.respond_to?(:file) ? @called_as.file : '(eval)'
      @line = @called_as.respond_to?(:line) ? @called_as.line : 0
      @called_as = '(anonymous)' if called_as.is_a?(Cons) or called_as.is_a?(Array)

      @called_from = if BusScheme.stack.empty? or !BusScheme.stack.last.respond_to? :called_as
                       '(top-level)'
                     else
                       BusScheme.stack.last.called_as
                     end
      
      locals.each { |k, v| immediate_set k, v }
    end

    alias_method :immediate_has_key?, :has_key?
    alias_method :immediate_set, :[]=
    alias_method :immediate_lookup, :[]

    # Just your regular hash stuff, only it takes the parent into account
    def has_key?(symbol)
      immediate_has_key?(symbol) or @parent && @parent.has_key?(symbol)
    end

    def [](symbol)
      if immediate_has_key?(symbol)
        immediate_lookup(symbol)
      else
        @parent && @parent[symbol]
      end
    end

    def []=(symbol, value)
      if !immediate_has_key?(symbol) and @parent && @parent.has_key?(symbol)
        @parent[symbol] = value
      else
        immediate_set symbol, value
      end
    end

    def trace
      "#{@file}:#{@line} in #{@called_from}"
    end
  end
end
