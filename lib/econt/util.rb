# frozen_string_literal: true

module Econt
  module Util
    def camel_case(str)
      str.gsub(/_([a-z])/) { ::Regexp.last_match(1).upcase }
    end

    def underscore(str)
      str.gsub(/([a-z])([A-Z])/, '\1_\2').downcase
    end

    def underscore_keys(hash)
      hash.each_with_object({}) do |(key, value), result|
        result[underscore(key.to_s)] = case value
                                       when Hash
                                         underscore_keys(value)
                                       when Array
                                         value.map { |v| underscore_keys(v) }
                                       else
                                         value
                                       end
      end
    end

    def camelize_keys(hash)
      hash.each_with_object({}) do |(key, value), result|
        result[camel_case(key.to_s)] = case value
                                       when Hash
                                         camelize_keys(value)
                                       when Array
                                         value.map { |v| camelize_keys(v) }
                                       else
                                         value
                                       end
      end
    end
  end
end
