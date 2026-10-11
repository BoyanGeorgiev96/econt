# frozen_string_literal: true

require 'spec_helper'
require_relative 'support/response_properties'

RSpec.describe ResponseProperties do
  include described_class

  let(:schema) { { 'type' => 'object', 'properties' => { 'someValue' => { 'type' => 'integer' } } } }

  it 'independently derives acronym and digit boundaries' do
    expect(%w[pdfURL hubNameEN courierRequestID URL step2Name code2 serviceOfficeNext30daysWorkTime]
      .map { |name| response_reader(name) })
      .to eq(%w[pdf_url hub_name_en courier_request_id url step2_name code2 service_office_next30days_work_time])
  end

  it 'rejects missing dot readers instead of checking only serialized attributes' do
    object = Struct.new(:wrong_reader).new(0)
    expect { assert_response_properties(object, { 'someValue' => 0 }, schema, {}) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, /missing .some_value/)
  end

  it 'rejects fixture payloads missing documented properties' do
    object = Struct.new(:some_value).new(0)
    expect { assert_response_properties(object, {}, schema, {}) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, /documented properties missing/)
  end

  it 'rejects wrong values even when the reader exists' do
    object = Struct.new(:some_value).new(9)
    expect { assert_response_properties(object, { 'someValue' => 0 }, schema, {}) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected 0, got 9/)
  end

  it 'rejects dropped nested array entries' do
    array_schema = { 'type' => 'array', 'items' => schema }
    expect { assert_response_properties([], [{ 'someValue' => 0 }], array_schema, {}) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, /array length changed/)
  end

  it 'rejects raw hashes as proof of nested dot access' do
    expect { assert_response_properties({ some_value: 0 }, { 'someValue' => 0 }, schema, {}) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, /raw hash/)
  end

  it 'checks false, zero, nil, primitives and temporal values without truthiness shortcuts' do
    scalar_schema = { 'type' => 'object', 'properties' => {
      'flag' => { 'type' => 'boolean' }, 'quantity' => { 'type' => 'integer' },
      'name' => { 'type' => 'string' }, 'day' => { 'type' => 'string', 'format' => 'date' },
      'createdTime' => { 'type' => 'string', 'format' => 'date-time' }
    } }
    raw = { 'flag' => false, 'quantity' => 0, 'name' => nil, 'day' => '2026-10-11',
            'createdTime' => '2026-10-11T10:30:45+02:00' }
    object = Struct.new(:flag, :quantity, :name, :day, :created_time)
                   .new(false, 0, nil, Date.new(2026, 10, 11), DateTime.iso8601(raw.fetch('createdTime')))
    assert_response_properties(object, raw, scalar_schema, {})
  end

  it 'continues ignoring unknown response fields as documented' do
    country = Econt::Models::Nomenclatures::Country.new('id' => 0, 'futureFlag' => false)
    expect(country.id).to eq(0)
    expect(country).not_to respond_to(:future_flag)
    expect(country.to_h).to eq(id: 0)
  end

  it 'preserves legacy pallet readers and explicit underscored constructor keys' do
    params = Econt::Models::Shipments::ReturnInstructionParams.new('emptyPallet80' => 3, 'empty_pallet_100' => 4)
    expect(params.empty_pallet80).to eq(3)
    expect(params.empty_pallet_80).to eq(3)
    expect(params.empty_pallet100).to eq(4)
    expect(params.empty_pallet_100).to eq(4)
    expect(JSON.parse(params.to_json)).to eq('emptyPallet80' => 3, 'emptyPallet100' => 4)
  end

  it 'preserves unsupported temporal representations rather than inventing an epoch unit' do
    status = Econt::Models::Shipments::ShipmentStatus.new('createdTime' => 1_792_000_000_000)
    expect(status.created_time).to eq(1_792_000_000_000)
  end
end
