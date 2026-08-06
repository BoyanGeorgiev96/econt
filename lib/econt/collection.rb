# frozen_string_literal: true

module Econt
  class Collection < MetaResource
    include Enumerable

    def initialize(source, model:, key:)
      @model = model
      @key = key
      @items = build_items(source)
    end

    def each(&block)
      @items.each(&block)
    end

    def to_a
      @items
    end

    def size
      @items.size
    end

    alias length size
    alias count size

    private

    def build_items(source)
      extract_raw_items(source).map do |item|
        item.is_a?(@model) ? item : @model.new(item)
      end
    end

    def extract_raw_items(source)
      case source
      when Hash
        source[@key] || source[@key.to_s] || []
      when Array
        source
      else
        []
      end
    end
  end
end
