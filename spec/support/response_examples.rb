# frozen_string_literal: true

module ResponseExamples
  MANIFEST = JSON.parse(File.read(File.expand_path('../fixtures/examples/response_schemas.json', __dir__)))
  SCHEMAS = MANIFEST.fetch('schemas')

  def response_example(name)
    path = File.expand_path("../fixtures/examples/responses/#{name}.json", __dir__)
    JSON.parse(File.read(path))
  end
end
