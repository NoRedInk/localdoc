require 'localdoc/api'

module Localdoc
  class ApplicationController < ActionController::Base
    def show
      @page_data = Localdoc::Api.show_page_data(
        Localdoc::Engine.routes.url_helpers,
        params[:path],
        params[:format],
      )
      render formats: :html
    end

    def update
      File.open(doc_full_path(params[:path], params[:format]), 'w') do |f|
        f.write params[:rawContent]
      end

      render json: {}
    end
  end
end
