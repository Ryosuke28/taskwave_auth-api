module Requests
  module JsonHelpers
    def json
      JSON.parse(response.body).symbolize_keys
    end
  end
end
