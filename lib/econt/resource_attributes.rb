# frozen_string_literal: true

require 'date'

module Econt
  module ResourceAttributes
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def fields
        @fields ||= {}
      end

      def field(name, opts = {})
        fields[name] = opts

        define_method(name) do
          coerce_field_value(@attributes[name], opts)
        end

        define_method("#{name}=") do |value|
          @attributes[name] = coerce_field_value(value, opts)
        end
      end
    end

    private

    def coerce_field_value(value, options)
      return nil if value.nil?

      case options[:type]
      when :integer then value.to_i
      when :string then value.to_s
      when :boolean then value == true || value.to_s.casecmp('true').zero?
      when :float, :double then value.to_f
      when :date then parse_temporal(value, Date)
      when :datetime then parse_temporal(value, DateTime)
      when :array then coerce_array(value, options[:of])
      when Class then value.is_a?(options[:type]) ? value : options[:type].new(value)
      else value
      end
    end

    def coerce_array(value, item_type)
      values = Array(value)
      return values if item_type.nil?

      values.map { |item| coerce_array_item(item, item_type) }
    end

    def coerce_array_item(value, type)
      return value if type.is_a?(Class) && value.is_a?(type)
      return type.new(value) if type.is_a?(Class)

      coerce_field_value(value, type: type)
    end

    def parse_temporal(value, type)
      return value if value.is_a?(type)

      type.parse(value.to_s)
    rescue ArgumentError
      value
    end
  end
end
