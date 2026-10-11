# frozen_string_literal: true

require 'spec_helper'
require_relative 'support/response_properties'
require_relative 'support/response_examples'

RSpec.describe Econt::Services::PaymentReport::PaymentReport do
  include ResponseExamples
  include ResponseProperties

  let(:client) do
    Econt::Client.new.tap do |value|
      value.username = 'offline-report'
      value.password = 'offline-report'
      value.setup_connection!
    end
  end
  let(:service) { described_class.new(client: client) }
  let(:url) { 'http://demo.econt.com/ee/services/PaymentReport/PaymentReportService.PaymentReport.json' }

  it 'unwraps the real response envelope into typed rows with accessible properties' do
    rows = [response_example('PaymentReport/success'), response_example('PaymentReport/null_scalars')]
    stub_request(:post, url).to_return(body: JSON.generate(PaymentReportRows: rows),
                                       headers: { 'Content-Type' => 'application/json' })
    result = service.payment_report
    expect(result).to be_a(Econt::Collection)
    expect(result.size).to eq(2)
    result.each_with_index do |row, index|
      expect(row).to be_a(Econt::Models::PaymentReport::PaymentReportRow)
      assert_response_properties(row, rows[index], ResponseExamples::SCHEMAS.fetch('PaymentReportRow'),
                                 ResponseExamples::SCHEMAS)
    end
  end

  it 'treats a null report envelope as an empty collection' do
    stub_request(:post, url).to_return(body: JSON.generate(PaymentReportRows: nil),
                                       headers: { 'Content-Type' => 'application/json' })
    expect(service.payment_report).to be_a(Econt::Collection).and be_empty
  end

  it 'retains the documented bare-row response compatibility' do
    raw = response_example('PaymentReport/success')
    stub_request(:post, url).to_return(body: JSON.generate(raw), headers: { 'Content-Type' => 'application/json' })
    result = service.payment_report
    expect(result).to be_a(Econt::Models::PaymentReport::PaymentReportRow)
    assert_response_properties(result, raw, ResponseExamples::SCHEMAS.fetch('PaymentReportRow'), ResponseExamples::SCHEMAS)
  end
end
