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
          case opts[:type]
          when :integer
            @attributes[name].to_i
          when :string
            @attributes[name].to_s
          when :boolean
            !!@attributes[name]
          when :float
            @attributes[name].to_f
          when :date
            if @attributes[name].is_a?(Date)
              @attributes[name]
            else
              begin
                Date.parse(@attributes[name].to_s)
              rescue StandardError
                @attributes[name] # Return the raw value if parsing fails
              end
            end
          when :array
            # Handle arrays of objects
            if opts[:of].is_a?(Class)
              @attributes[name]&.map do |item|
                item.is_a?(opts[:of]) ? item : opts[:of].new(item)
              end
            else
              @attributes[name]
            end
          when Class
            opts[:type].new(@attributes[name])
          else
            @attributes[name]
          end
        end

        define_method("#{name}=") do |value|
          @attributes[name] = case opts[:type]
                              when :integer
                                value.to_i
                              when :string
                                value.to_s
                              when :boolean
                                !!value
                              when :float
                                value.to_f
                              when :date
                                if value.is_a?(Date)
                                  value
                                else
                                  begin
                                    Date.parse(value.to_s)
                                  rescue StandardError
                                    value # Store the raw value if parsing fails
                                  end
                                end
                              when :array
                                # Handle arrays of objects
                                if opts[:of].is_a?(Class)
                                  value&.map do |item|
                                    item.is_a?(opts[:of]) ? item : opts[:of].new(item)
                                  end
                                else
                                  value
                                end
                              else
                                value
                              end
        end
      end
    end
  end
end
