require 'rails_helper'

describe Localdoc::ApplicationController do
  it "GET /" do
    get :show, use_route: :localdoc
    expect(response).to be_success
    expect(assigns(:page_data)).to(
      include(
        :markdownOptions,
        model: include(
          :allDocs,
          :filePath,
          :savePath,
          :editable,
          :blockingError)))
  end

  it "GET /path/to/non-existent-doc.json" do
    get :show, path: "path/to/non-existent-doc.json", use_route: :localdoc
    expect(response).to be_success
    expect(assigns(:page_data)).to include(model: include(blockingError: "File Not Found"))
  end
end
