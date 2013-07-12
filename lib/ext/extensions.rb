class Hash
  def deep_symbolize_keys
    hash = self
    hash.inject({}){|result, (key, value)|
      new_key = case key
                when String then key.to_sym
                else key
                end
    new_value = case value
                when Hash then value.deep_symbolize_keys
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
      when Struct then e.to_h
      when Array then e.simplify_elements
      else e
      end
    end
  end

end

class Struct

  def to_h
    hash = self.class.members.inject({}) do |h, m| 
      v = self[m]
      h[m] = case v
             when Symbol then v.to_s
             when Struct then v.to_h
             when Array then v.simplify_elements
             else v
             end
      h
    end

    hash.deep_symbolize_keys
  end

end