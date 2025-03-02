# frozen_string_literal: true

require_relative 'econt/version'
require_relative 'econt/error'
require_relative 'econt/client'
require_relative 'econt/camel_case_middleware'
require_relative 'econt/resource'

# Recursively require all Ruby files inside `services/`
Dir[File.join(__dir__, 'econt/services/**/*.rb')].sort.each { |file| require_relative file }

module Econt
  # Main namespace for the Econt gem
end
