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
          normalized = Econt::Util.underscore_keys(source)
          if key && normalized.key?(key.to_s)
            normalized[key.to_s]
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
      @error = Econt::Models::Error.build_from(attributes) unless is_a?(Econt::Models::Error)
      apply_attributes(attributes)
      self.error = @error if @error && respond_to?(:error=)
    end

    attr_reader :error

    def error?
      !error.nil?
    end

    def method_missing(method_name, *args, &)
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
      deep_to_h(@attributes)
    end

    def to_json(*)
      camelize_keys(to_h).to_json(*)
    end

    def apply_attributes(new_attributes)
      underscore_keys(new_attributes).each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end

    private

    def deep_to_h(value)
      case value
      when Econt::Model
        value.to_h
      when Hash
        value.transform_values { |item| deep_to_h(item) }
      when Array
        value.map { |item| deep_to_h(item) }
      else
        value
      end
    end
  end
end
