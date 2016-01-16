require "localdoc/engine"

module Localdoc
  # Will be joined against Rails.root.
  mattr_accessor :document_root
  # markdown-it options + {mermaid: mermaid_options}
  mattr_accessor :markdown_options
end
