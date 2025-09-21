require 'rails_helper'

RSpec.describe 'UploadsController', type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: "/uploads/index").to route_to("uploads#index")
    end
    it 'routes to #new' do
      expect(get: "/uploads/new").to route_to("uploads#new")
    end
    it 'routes to #create' do
      expect(get: "/uploads/create").to route_to("uploads#create")
    end
    it 'routes to #show' do
      expect(get: "/uploads/show").to route_to("uploads#show")
    end
    it 'routes to #destroy' do
      expect(get: "/uploads/destroy").to route_to("uploads#destroy")
    end
  end
end
