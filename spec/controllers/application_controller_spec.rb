require 'rails_helper'

describe Localdoc::ApplicationController do
  it "GET /" do
    get :show, use_route: :localdoc
    expect(response).to be_success
  end

  it "GET /path/to/non-existent-doc.json" do
    get :show, path: "path/to/non-existent-doc.json", use_route: :localdoc
    expect(response).to be_success
    expect(assigns(:blocking_error)).to include("File Not Found")
  end
end
