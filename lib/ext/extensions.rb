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

      new_v = case v
              when Symbol then v.to_s
              when Struct || DefStruct then v.to_h
              when Array then v.simplify_elements
              else v
              end
      if new_v.nil? 
        h
      else
        h[m] = new_v
        h
      end
    end

    hash.deep_symbolize_keys
  end


end

# Taken from https://github.com/splendeo/activerecord-reset-pk-sequence
module ActiveRecord
  class Base
    def self.reset_pk_sequence
      case ActiveRecord::Base.connection.adapter_name
      when 'SQLite'
        new_max = maximum(primary_key) || 0
        update_seq_sql = "UPDATE sqlite_sequence SET seq = #{new_max} WHERE name = '#{table_name}';"
        ActiveRecord::Base.connection.execute(update_seq_sql)
      when 'Mysql'
        new_max = maximum(primary_key) + 1 || 1
        update_seq_sql = "ALTER TABLE '#{table_name}' AUTO_INCREMENT = #{new_max};"
        ActiveRecord::Base.connection.execute(update_seq_sql)
      when 'PostgreSQL'
        ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
      else 
        raise "Task not implemented for this DB adapter"
      end 
    end
  end
end

