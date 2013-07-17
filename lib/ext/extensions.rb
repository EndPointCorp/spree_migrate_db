class Hash
  def deep_symbolize_keys
    hash = self
    hash.inject({}){|result, (key, value)|
      new_key = case key
                when String then key.to_sym
                else key
                end
      new_value = case value
                  when Symbol then value.to_s
                  when Hash then value.deep_symbolize_keys
                  when Array then value.simplify_elements
                  else value
                  end
      result[new_key] = new_value
      result
    }
  end
end

class Array

  def simplify_elements
    self.map do |e|
      case e
      when Symbol then e.to_s
      when DefStruct then e.stringify_values
      when Hash then e.deep_symbolize_keys
      when Array then e.simplify_elements
      else e
      end
    end
  end

end

class DefStruct < Struct

  def <=>(other)
    self.to_s <=> other.to_s
  end

  def stringify_values
    s = self.dup
    s.each_pair do |k,v|
      s[k] = v.kind_of?(Symbol) ? v.to_s : v
    end
    s
  end

  def to_h
    hash = self.class.members.inject({}) do |h, m| 
      v = self[m]
      h[m] = case v
             when Symbol then v.to_s
             when Struct || DefStruct then v.to_h
             when Array then v.simplify_elements
             else v
             end
      h
    end

    hash.deep_symbolize_keys
  end

end
