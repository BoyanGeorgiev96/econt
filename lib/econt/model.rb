# frozen_string_literal: true

module Econt
  class Model
    include Econt::ResourceAttributes
    include Econt::Util

    class << self
      def collection_key(value = nil)
        return @collection_key || Econt::Util.pluralize(name).to_sym unless value

        @collection_key = value
      end

      def collection(source)
        Econt::Collection.new(source, model: self, key: collection_key)
      end

      def build(source, key: nil)
        data = extract_source(source, key)
        new(data.is_a?(Hash) ? data : {})
      end

      private

      def extract_source(source, key)
        case source
        when Hash
          if key && (source.key?(key) || source.key?(key.to_s))
            source[key] || source[key.to_s]
          else
            source
          end
        else
          source
        end
      end
    end

    def initialize(attributes = {})
      @attributes = {}
      apply_attributes(attributes)
    end

    def method_missing(method_name, *args, &block)
      if @attributes.key?(method_name)
        @attributes[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @attributes.key?(method_name) || super
    end

    def to_h
      @attributes
    end

    def to_json(*args)
      camelize_keys(@attributes).to_json(*args)
    end

    def apply_attributes(new_attributes)
      new_attributes.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end
  end
end
