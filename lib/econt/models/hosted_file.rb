# frozen_string_literal: true

module Econt
  module Models
    class HostedFile < Econt::Model
      field :id, type: :integer
      field :filename, type: :string
      field :mime_type, type: :string
      field :url, type: :string
      field :content, type: :string
    end
  end
end
