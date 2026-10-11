# frozen_string_literal: true

require 'ripper'
require 'yard'

RSpec.describe 'Econt API documentation' do
  service_classes = [
    Econt::Services::Nomenclatures::Nomenclatures,
    Econt::Services::Nomenclatures::Address,
    Econt::Services::Shipments::Label,
    Econt::Services::Shipments::Shipment,
    Econt::Services::Profile::Profile,
    Econt::Services::PaymentReport::PaymentReport,
    Econt::Services::ThreeWayLogistics::ThreeWayLogistics
  ].freeze

  reference = File.read(File.expand_path('../docs/API.md', __dir__))
  YARD::Registry.clear
  YARD.parse(File.expand_path('../lib/econt/services/*/*.rb', __dir__))

  service_classes.each do |service|
    service.public_instance_methods(false).sort.each do |method_name|
      it "documents #{service}##{method_name} and every parameter" do
        documented = YARD::Registry.at("#{service}##{method_name}")
        expect(documented).not_to be_nil
        expect(documented.docstring).not_to be_empty
        expect(documented.tags(:return)).not_to be_empty
        expect(documented.tags(:example)).not_to be_empty
        expect(documented.tags(:raise)).not_to be_empty
        expect(reference).to include("### #{method_name}\n")
        expect(reference).to include(documented.signature.delete_prefix('def '))
        expect(reference).to include("](##{method_name})")

        parameters = service.instance_method(method_name).parameters.map(&:last)
        expect(documented.tags(:param).map(&:name)).to match_array(parameters.map(&:to_s))
        documented.tags(:example).each do |example|
          expect(Ripper.sexp(example.text)).not_to be_nil, "Invalid Ruby example: #{documented.path}"
        end
      end
    end
  end

  it 'contains syntactically valid Ruby snippets without executing them' do
    examples = reference.scan(/```ruby\n(.*?)```/m).flatten
    expect(examples.size).to be >= 26
    examples.each_with_index do |example, index|
      expect(Ripper.sexp(example)).not_to be_nil, "Invalid reference snippet #{index + 1}"
    end
  end
end
