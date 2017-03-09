require "aker-set-client/version"
require "json_api_client"

module SetClient
  class Base < JsonApiClient::Resource
    self.site=ENV['SET_URL']
  end

  class Set < Base
    custom_endpoint :clone, on: :member, request_method: :post
    custom_endpoint :'relationships/materials', on: :member, request_method: :post

    def uuid
        id
    end

    def create_locked_clone(new_name)
        copy = self.clone(data: { attributes: { name: new_name }}).first
        copy.update_attributes(locked: true)
        copy
    end

    def set_materials(uuids)
        self.send(:'relationships/materials', data: uuids.map {|uuid| { id: uuid, type: 'materials' }} )
    end

    def self.get_set_names(set_uuids)
        set_uuids.map { |uuid| summarise(find(uuid).first) }
    end

    def self.summarise(set)
        { uuid: set.id, name: set.name }
    end

    def self.find_with_materials(id)
        includes(:materials).find(id)
    end

  end

  class Material < Base
  end
end
