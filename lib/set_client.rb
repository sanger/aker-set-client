require "set_client/version"
require "json_api_client"

module SetClient
  class Base < JsonApiClient::Resource
    self.site=ENV['SET_URL']
  end

  class Set < Base
    custom_endpoint :clone, on: :member, request_method: :post

    def create_locked_clone(new_name)
        copy = self.clone(data: { attributes: { name: new_name }})
        copy.update_attributes(locked: true)
        copy
    end

    def uuid
        id
    end
  end
end
