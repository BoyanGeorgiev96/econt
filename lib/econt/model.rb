# frozen_string_literal: true

module Econt
  class Model
    include Econt::ResourceAttributes
    include Econt::Util

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
