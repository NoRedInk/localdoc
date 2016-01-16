module Localdoc
  class ApplicationController < ActionController::Base
    def show
      doc_content, blocking_error = read_doc
      model = {
        allDocs: all_docs,
        filePath: doc_relative_path.to_s,
        savePath: update_path(path: doc_relative_path.to_s),
        editable: editable?,
        sections: sections(doc_content),
        blockingError: blocking_error,
      }
      @page_data = {
        model: model,
        markdownOptions: Localdoc.markdown_options,
      }
      render formats: :html
    end

    def update
      File.open(doc_full_path, 'w') do |f|
        f.write serialize_sections
      end

      render json: {}
    end

    private

    def doc_root
      fail "Set `Localdoc.document_root` to your documents directory." if Localdoc.document_root.nil?
      @doc_root ||= Pathname.new Rails.root.join(Localdoc.document_root)
    end

    def doc_relative_path
      @doc_relative_path ||= "#{params[:path]}.#{params[:format]}"
    end

    def doc_full_path
      @doc_full_path ||= doc_root + doc_relative_path
    end

    def sections(doc_content)
      return [] if doc_content.blank?
      [
        {title: "", extension: params[:format], rawContent: doc_content}
      ]
    end

    # update

    def serialize_sections
      params[:sections].map do |section|
        section[:title] + "\n\n" + section[:rawContent]
      end.join("\n\n")
    end

    # readers

    def all_docs
      read_directory_tree(doc_root, strip: doc_root)[:children]
    end

    def read_doc
      if params[:path].blank?
        blocking_error = 'Pick a document to view and maybe edit.'
      elsif File.exist? doc_full_path
        doc = File.read doc_full_path
      else
        blocking_error = 'File Not Found'
      end
      [doc, blocking_error]
    end

    # reader helpers

    def read_directory_tree(pathname, name: nil, strip: nil)
      node = {name: name || pathname.to_s, url: path_for_file(pathname, strip)}
      node[:children] = children = []

      return node unless pathname.exist?

      pathname.each_child do |entry|
        if entry.directory?
          children << read_directory_tree(entry, name: entry.basename.to_s, strip: strip)
        else
          children << {name: entry.basename.to_s, url: path_for_file(entry, strip), children: []}
        end
      end

      node
    end

    def path_for_file(pathname, strip)
      stripped = strip.nil? ? pathname : pathname.relative_path_from(strip)
      show_path stripped
    end

    def editable?
      Rails.env.development?
    end
  end
end
