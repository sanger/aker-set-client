require "spec_helper"

describe SetClient do
  it "has a version number" do
    expect(SetClient::VERSION).not_to be nil
  end

  it "has a uuid" do
    expect(SetClient::Set.new).to respond_to :uuid
  end

  it "is connected to the json api" do
    url='http://localhost:9999/api/v1/'
    id="123"
    SetClient::Base.site = url

    stub_request(:get, url+"sets/"+id).
         with(headers: {'Accept'=>'application/vnd.api+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/vnd.api+json', 'User-Agent'=>'Faraday v0.11.0'}).
         to_return(status: 200, body: "", headers: {})
    stub_request(:get, url+'/sets')
        .to_return(status: 200, body: {id: id}.to_json, headers: {})

    expect(SetClient::Set.find(id)).not_to be nil
  end
end
