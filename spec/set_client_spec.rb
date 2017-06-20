require "spec_helper"

describe SetClient do
  describe '#VERSION' do
    it { expect(SetClient::VERSION).not_to be_nil }
  end

  describe SetClient::Set do
    describe '#uuid' do
      it "has a uuid when new" do
        expect(SetClient::Set.new).to respond_to :uuid
      end
      it "has the appropriate uuid when retrieved" do
        id = "123"
        setup_set(id)
        s = SetClient::Set.find(id).first
        expect(s.uuid).to eq(id)
      end
    end

    it "can read from the json api" do
      id = "123"
      setup_set(id, 'Arkansas')
      rs = SetClient::Set.find(id)
      expect(rs).not_to be_nil

      expect(rs.length).to eq 1
      s = rs.first
      expect(s.id).to eq id
      expect(s.name).to eq 'Arkansas'
      expect(s.locked).to eq false
    end

    describe '#create_locked_clone' do
      it "can create a locked clone" do
        id = "123"
        setup_set(id)
        s = SetClient::Set.find(id).first
        c = s.create_locked_clone('Wyoming')
        expect(c.id).not_to eq id
        expect(c.locked).to eq true
      end
    end

    describe '#summarise' do
      it "summarises a set" do
        id = "123"
        setup_set(id)
        s = SetClient::Set.find(id).first
        expect(SetClient::Set.summarise(s)).to eq({ uuid: s.uuid, name: s.name })
      end
    end

    describe '#get_set_names' do
      before do
        setup_set("1", "Colorado")
        setup_set("2", "Connecticut")
        setup_set("3", "Delaware")
      end
      it "returns the set names" do
        results = SetClient::Set.get_set_names(["1", "2"])
        expected = [
          { uuid: "1", name: "Colorado" },
          { uuid: "2", name: "Connecticut" },
        ]
        expect(results).to eq(expected)
      end
    end

    describe '#find_with_materials' do
      it "returns the set with material ids" do
        id = "1"
        material_ids = ["0dea44a4-91bd-48df-9322-7cb5f952711d", "e6713111-f4f0-401d-aa9b-df5846236296" ]
        setup_set(id, "Florida", material_ids)
        rs = SetClient::Set.find_with_materials(id)
        expect(rs).not_to be_nil
        expect(rs.length).to eq 1
        s = rs.first
        expect(s.id).to eq(id)
        expect(s.name).to eq("Florida")
        expect(s.materials).not_to be_nil
        expect(s.materials.length).to eq(material_ids.length)
        expect(s.materials.map { |m| m.id }).to eq(material_ids)
      end
    end

    describe '#set_materials' do
      before do
        setup_set("1", "Hawaii")
        @relationship_url = "http://localhost:9999/api/v1/sets/1/relationships/materials"

        stub_request(:post, @relationship_url).
          to_return(status: 200, body: "", headers: response_headers)
      end

      it "posts the new relationships" do
        s = SetClient::Set.find("1").first
        material_ids = ["0dea44a4-91bd-48df-9322-7cb5f952711d", "e6713111-f4f0-401d-aa9b-df5846236296" ]
        s.set_materials(material_ids)

        material_data = material_ids.map do |mid|
          {
            id: mid,
            type: "materials",
          }
        end

        assert_requested :post, @relationship_url,
          body: { data: material_data }.to_json, headers: request_headers,
          times: 1
      end
    end

  end


private

  let(:content_type) { 'application/vnd.api+json' }
  let(:request_headers) { { 'Accept'=>content_type, 'Content-Type'=>content_type } }
  let(:response_headers) { { 'Content-Type'=>content_type } }

  def setup_set(id, name='Alabama', material_ids=[])
    url='http://localhost:9999/api/v1/'
    #id="123"
    SetClient::Base.site = url

    urlid = url+"sets/"+id

    setdata = make_setdata(id, name, urlid, material_ids)

    cloneid="9999"
    urlclone = url+'sets/'+cloneid

    clonedata = make_setdata(cloneid, 'Wyoming', urlclone)

    stub_request(:get, urlid)
         .with(headers: request_headers)
         .to_return(status: 200, body: { data: setdata }.to_json, headers: response_headers)

    stub_request(:get, url+'/sets')
        .with(headers: request_headers)
        .to_return(status: 200, body: { data: [setdata] }.to_json, headers: response_headers)

    incl = material_ids.map do |mid|
      {
        id: mid,
        type: "materials",
        links: { self: "http://localhost:5000/materials/"+mid }
      }
    end

    stub_request(:get, urlid+"?include=materials").
         with(headers: request_headers).
         to_return(status: 200, body: { data: [setdata], included: incl }.to_json, headers: response_headers)

    stub_request(:post, urlid+"/clone")
         .with(
            body: { data: { attributes: { name: "Wyoming" }}}.to_json,
            headers: request_headers
         )
         .to_return(status: 200, body: { data: clonedata }.to_json, headers: response_headers)

    clonedata[:attributes][:locked] = true

    stub_request(:patch, urlclone)
        .with(
           body: { data: { id: cloneid, type: "sets", attributes: { locked: true }}}.to_json,
           headers: request_headers
        )
        .to_return(status: 200, body: { data: clonedata }.to_json, headers: response_headers)

    id
  end

  def make_setdata(id, name, urlid, material_ids=[])
    rel_mat = {
      links: {
        self: urlid+"/relationships/materials",
        related: urlid+"/materials",
      }
    }
    unless material_ids.empty?
      rel_mat[:data] = material_ids.map do |mid|
        {
          type: "materials",
          id: mid,
        }
      end
    end
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
        materials: rel_mat,
      },
      meta: { size: material_ids.length },
    }
  end
end
