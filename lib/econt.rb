# frozen_string_literal: true

require_relative "econt/version"

module Econt
  autload :Client, "econt/client"
  autload :Error, "econt/error"
  autload :Object, "econt/object"
  autload :Resource, "econt/resource"
end
