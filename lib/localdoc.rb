require "localdoc/engine"

module Localdoc
  # Will be joined against Rails.root.
  mattr_accessor :document_root
end
