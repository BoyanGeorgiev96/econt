# frozen_string_literal: true

require 'spec_helper'
require_relative 'support/recorded_responses'

RSpec.describe 'reviewed API recordings', :replay do
  include RecordedResponses

  it 'has reviewed cassettes to replay' do
    expect(RecordedResponses::FILES).not_to be_empty
  end

  RecordedResponses::FILES.each do |file|
    name = file.delete_prefix("#{RecordedResponses::ROOT}/").delete_suffix('.yml')
    it "replays every interaction in #{name}" do
      client = replay_client
      VCR.use_cassette(name, record: :none, allow_unused_http_interactions: false) do
        interactions = archived_interactions(file)
        expect(interactions).not_to be_empty
        interactions.each { |interaction| replay_interaction(interaction, client) }
      end
    end
  end

  %i[none all].each do |record|
    it "blocks missing recordings even with record: #{record}" do
      VCR.use_cassette('missing-replay-safety-check', record: record) do
        expect { Faraday.post('http://demo.econt.com/ee/services/unrecorded.json') }
          .to raise_error(RuntimeError, /Network requests are forbidden/)
      end
    end
  end

  it 'blocks unmatched requests in an existing cassette' do
    VCR.use_cassette('econt_demo/nomenclatures', record: :none) do
      expect { Faraday.post('http://demo.econt.com/ee/services/unmatched.json') }
        .to raise_error(RuntimeError, /Network requests are forbidden/)
    end
  end

  it 'blocks localhost rather than allowing a network exception' do
    expect { Faraday.get('http://127.0.0.1:9/') }
      .to raise_error(RuntimeError, /Network requests are forbidden/)
    expect(WebMock.net_connect_allowed?('http://127.0.0.1:9/')).to be false
  end

  it 'blocks WebMock network access even if VCR is turned off' do
    VCR.turned_off do
      expect { Faraday.get('http://127.0.0.1:9/') }
        .to raise_error(RuntimeError, /Network requests are forbidden/)
    end
  end
end
