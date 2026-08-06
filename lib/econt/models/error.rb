# frozen_string_literal: true

module Econt
  module Models
    class Error < Econt::Model
      field :type, type: :string
      field :message, type: :string
      field :fields, type: :string
      field :inner_errors, type: Econt::Models::Error
    end
  end
end
