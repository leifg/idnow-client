require 'spec_helper'

RSpec.describe IdnowRuby::Response do
  let(:successful_id) { 'IBA-H5FD8' }
  let(:successful_raw_response) { "{ \"id\": \"#{successful_id}\" }" }
  let(:failure_raw_response) do
    '{
                                  "errors": [{
                                          "cause": "INVALID_LOGIN_TOKEN",
                                          "id": "487800773",
                                          "key": null,
                                          "message": null
                                  }]
                                }'
  end
  let(:idnow_response) { IdnowRuby::Response.new(response) }

  describe '#new' do
    let(:response) { successful_raw_response }
    subject { idnow_response }
    it 'sets data to the hash resulting of parsing the raw_response' do
      data = subject.instance_variable_get('@data')
      expect(data).to be_a Hash
    end
  end

  describe '#id' do
    subject { idnow_response.id }
    context 'given raw response without errors' do
      let(:response) { successful_raw_response }
      it 'returns the id' do
        expect(subject).to eq 'IBA-H5FD8'
      end
    end

    context 'given a raw response with errors ' do
      let(:response) { failure_raw_response }
      it 'returns nil' do
        expect(subject).to eq nil
      end
    end
  end

  describe '#errors' do
    subject { idnow_response.errors }
    context 'given raw response without errors' do
      let(:response) { successful_raw_response }
      it 'returns nil' do
        expect(subject).to eq nil
      end
    end

    context 'given a raw response with errors ' do
      let(:response) { failure_raw_response }
      it 'returns the errors' do
        expect(subject).to eq(
          [
            { 'cause' => 'INVALID_LOGIN_TOKEN',
              'id' => '487800773',
              'key' => nil,
              'message' => nil }
          ]
        )
      end
    end
  end

  describe '#errors?' do
    subject { idnow_response.errors? }
    context 'given raw response without errors' do
      let(:response) { successful_raw_response }
      it { is_expected.to be_falsey }
    end

    context 'given a raw response with errors ' do
      let(:response) { failure_raw_response }
      it { is_expected.to be_truthy }
    end
  end

  describe '#redirect_url' do
    subject { idnow_response.redirect_url }
    context 'of a response with errors' do
      let(:response) { failure_raw_response }
      it { is_expected.to be nil }
    end
    context 'of a successful response' do
      let(:response) { successful_raw_response }
      context 'when env is :test' do
        before do
          IdnowRuby.env = :test
        end
        it 'returns a test redirect url' do
          expect(subject).to eq "https://go.test.idnow.de/#{successful_id}"
        end
      end
      context 'when env is :live' do
        before do
          IdnowRuby.env = :live
        end
        it 'returns a live redirect url' do
          expect(subject).to eq "https://go.idnow.de/#{successful_id}"
        end
      end
    end
  end
end