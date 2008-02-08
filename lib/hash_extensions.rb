class Hash
  alias_method :call, :[]
  alias_method :old_lookup, :[]
  alias_method :old_has_key, :has_key?

  def has_key?(key)
    old_has_key(key) or old_has_key(key.to_sym)
  end
  
  def [](key)
    if old_has_key(key)
      old_lookup(key)
    else
      old_lookup(key.to_sym)
    end
  end
end
