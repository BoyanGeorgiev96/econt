# frozen_string_literal: true

RSpec.describe 'Econt demo API contract', :live do
  around do |example|
    VCR.use_cassette(example.metadata.fetch(:cassette)) { example.run }
  end

  before do
    Econt::Client.configure do |config|
      config.username = ENV.fetch('ECONT_USERNAME')
      config.password = ENV.fetch('ECONT_PASSWORD')
      config.base_url = ENV.fetch('ECONT_BASE_URL', 'http://demo.econt.com/ee/services/')
    end
  end

  let(:country_code) { ENV.fetch('ECONT_CONTRACT_COUNTRY_CODE', 'BGR') }
  let(:city_id) { Integer(ENV.fetch('ECONT_CONTRACT_CITY_ID', '41'), 10) }
  let(:address) do
    {
      city: { id: city_id, country: { code3: country_code } },
      street: 'бул. Витоша',
      num: '1'
    }
  end

  it 'loads typed country nomenclatures', cassette: 'econt_demo/nomenclatures' do
    countries = nomenclatures.get_countries

    expect(countries).not_to be_empty
    expect(countries.first).to be_a(Econt::Models::Nomenclatures::Country)
  end

  it 'loads typed city nomenclatures', cassette: 'econt_demo/cities' do
    cities = nomenclatures.get_cities(country_code: country_code)

    expect(cities).not_to be_empty
    expect(cities.first).to be_a(Econt::Models::Nomenclatures::City)
  end

  it 'loads typed region nomenclatures', cassette: 'econt_demo/regions' do
    regions = nomenclatures.get_regions(country_code: country_code)

    expect(regions).not_to be_empty
    expect(regions.first).to be_a(Econt::Models::Nomenclatures::Region)
  end

  it 'loads typed office nomenclatures', cassette: 'econt_demo/offices' do
    offices = nomenclatures.get_offices(country_code: country_code, city_id: city_id)

    expect(offices).not_to be_empty
    expect(offices.first).to be_a(Econt::Models::Nomenclatures::Office)
  end

  it 'loads typed street nomenclatures', cassette: 'econt_demo/streets' do
    streets = nomenclatures.get_streets(city_id: city_id)

    expect(streets).not_to be_empty
    expect(streets.first).to be_a(Econt::Models::Nomenclatures::Street)
  end

  it 'loads typed quarter nomenclatures', cassette: 'econt_demo/quarters' do
    quarters = nomenclatures.get_quarters(city_id: city_id)

    expect(quarters).not_to be_empty
    expect(quarters.first).to be_a(Econt::Models::Nomenclatures::Quarter)
  end

  it 'validates a synthetic address', cassette: 'econt_demo/address_validation' do
    result = addresses.validate_address(address)

    expect(result).to be_a(Econt::Models::Nomenclatures::AddressValidationResponse)
    expect(result.validation_status).not_to be_nil
    expect(result.address).to be_a(Econt::Models::Nomenclatures::Address) unless result.error?
  end

  it 'loads typed offices nearest to a synthetic address', cassette: 'econt_demo/nearest_offices' do
    offices = addresses.get_nearest_offices(address: address, shipment_type: 'pack')

    expect(offices).not_to be_empty
    expect(offices.first).to be_a(Econt::Models::Nomenclatures::Office)
  end

  def nomenclatures
    @nomenclatures ||= Econt::Services::Nomenclatures::Nomenclatures.new
  end

  def addresses
    @addresses ||= Econt::Services::Nomenclatures::Address.new
  end
end
