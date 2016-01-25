# localdoc

This is a Rails 3 Engine for navigating, viewing and editing local plaintext documents.

* Markdown files: rendered using [markdown-it](https://markdown-it.github.io/)
  * With special extension for [Mermaid](http://knsv.github.io/mermaid/) diagram support
* Everthing else: rendered as a code block highlighted with [highlight.js](https://highlightjs.org/)

## Installation

In your Gemfile, add this gem within the group that makes sense for you. For example:

```ruby
group :development, :staging do
  gem 'localdoc', github: 'NoRedInk/localdoc', branch: 'stable'
end
```

Follow the gem's post installation message to generate the required assets for your development environment.

In config/routes.rb, mount the engine at the path of your choice. For example:

```ruby
if Rails.env.development? || Rails.env.staging?
  namespace :dev do
    mount Localdoc::Engine, at: "/docs"
  end
end
```


In config/initializers/localdoc.rb, specify the path to the root of your documentation files. For example:

```ruby
if Rails.env.development? || Rails.env.staging?
  Localdoc.document_root = "docs"

  # You can also pass options to markdown-it and Mermaid:
  Localdoc.markdown_options = {
    breaks: true,
    mermaid: {
      sequenceDiagram: {
        mirrorActors: true
      }
    }
  }
end
```

## How to write Mermaid diagrams

Write your diagram in a code block and specify `mermaid` as the language.

    ```mermaid
    graph LR
    Hello-->World
    ```

## Note to contributors: how to push a new version

As a pre-alpha product, this gem is not published on rubygems.org yet.
To make new changes available, push to the `stable` branch.
