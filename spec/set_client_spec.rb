require "spec_helper"

describe SetClient do
  it "has a version number" do
    expect(SetClient::VERSION).not_to be nil
  end

  it "has a uuid" do
    expect(SetClient::Set.new).to respond_to :uuid
  end

  it "can read from the json api" do
    id = setup_set
    rs = SetClient::Set.find(id)
    expect(rs).not_to be nil

    expect(rs.length).to eq 1
    s = rs.first
    expect(s.id).to eq id
    expect(s.name).to eq 'Alabama'
    expect(s.locked).to eq false
  end

  it "can create a locked clone" do
    id = setup_set
    s = SetClient::Set.find(id).first
    c = s.create_locked_clone('Alaska')
    expect(c.id).to_not eq id
    expect(c.locked).to eq true
  end

private
  def setup_set
    url='http://localhost:9999/api/v1/'
    id="123"
    SetClient::Base.site = url

    urlid = url+"sets/"+id

    setdata = make_setdata(id, 'Alabama', urlid)

    cloneid="456"
    urlclone = url+'sets/'+cloneid

    clonedata = make_setdata(cloneid, 'Alaska', urlclone)

    content_type = 'application/vnd.api+json'
    requestheaders = { 'Accept'=>content_type, 'Content-Type'=>content_type }
    responseheaders = { 'Content-Type'=>content_type }

    stub_request(:get, urlid)
         .with(headers: requestheaders)
         .to_return(status: 200, body: { data: setdata }.to_json, headers: responseheaders)

    stub_request(:get, url+'/sets')
        .with(headers: requestheaders)
        .to_return(status: 200, body: { data: [setdata] }.to_json, headers: responseheaders)

    stub_request(:post, urlid+"/clone")
         .with(
            body: { data: { attributes: { name: "Alaska" }}}.to_json,
            headers: requestheaders
         )
         .to_return(status: 200, body: { data: clonedata }.to_json, headers: responseheaders)

    clonedata[:attributes][:locked] = true

    stub_request(:patch, urlclone)
        .with(
           body: { data: { id: cloneid, type: "sets", attributes: { locked: true }}}.to_json,
           headers: requestheaders
        )
        .to_return(status: 200, body: { data: clonedata }.to_json, headers: responseheaders)

    id
  end

  def make_setdata(id, name, urlid)
    {
      id: id,
      type: "sets",
      links: { self: urlid },
      attributes: {
        name: name,
        created_at: "2017-01-01T00:00:00.000Z",
        locked: false,
      },
      relationships: {
        materials: {
          links: {
            self: urlid+"/relationships/materials",
            related: urlid+"/materials",
          },
        },
      },
      meta: { size: 1 },
    }
  end
end
