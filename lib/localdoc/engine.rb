require "rubygems"
require "rails"
require "action_view"
require "haml"
require "bourbon"
require "neat"

module Localdoc
  class Engine < ::Rails::Engine
    isolate_namespace Localdoc

    initializer "localdoc.assets.configue" do |app|
      app.config.assets.configure do |env|
        env.unregister_postprocessor 'application/javascript', Sprockets::SafetyColons
      end
    end

    initializer "localdoc.assets.precompile" do |app|
      app.config.assets.precompile += %w(localdoc/application.css localdoc/bundle.js)
    end
  end
end
