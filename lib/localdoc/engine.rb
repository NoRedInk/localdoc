require "rubygems"
require "rails"
require "action_view"
require "haml"

module Localdoc
  class Engine < ::Rails::Engine
    isolate_namespace Localdoc
    engine_name 'localdoc'

    initializer "localdoc.assets.precompile" do |app|
      app.config.assets.precompile += %w(localdoc/bundle.js)
    end
  end
end
