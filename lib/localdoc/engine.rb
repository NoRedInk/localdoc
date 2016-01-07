module Localdoc
  class Engine < ::Rails::Engine
    isolate_namespace Localdoc

    initializer "localdoc.assets.precompile" do |app|
      app.config.assets.precompile += %w(application.css application.js)
    end
  end
end
