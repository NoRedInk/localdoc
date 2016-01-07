require "rails"
require "action_view"
require "haml"
require "localdoc/engine"

module Localdoc
  mattr_accessor :document_root
end
