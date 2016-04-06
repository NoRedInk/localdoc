require 'localdoc/doc_tree'

module Localdoc
  module Api
    module_function

    def show_page_data(url_helpers, path, format, file_suffix: '', editable: true)
      document = read_doc(path, format)

      model = {
        allDocs: Localdoc::DocTree.from_root(url_helpers, file_suffix: file_suffix),
        savePath: url_helpers.update_path(path: document[:filePath]),
        editable: editable && editable_env?,
      }.merge(document)

      @page_data = {
        model: model,
        markdownOptions: Localdoc.markdown_options,
      }
    end

    # readers

    def read_doc(path, format)
      document = {
        extension: "",
        rawContent: "",
        filePath: doc_relative_path(path, format).to_s,
        blockingError: nil,
      }
      if path.blank? || path == "."
        document[:blockingError] = 'Pick a document to view and maybe edit.'
        return document
      end

      full_path = doc_full_path(path, format)

      if File.exist? full_path
        document[:rawContent] = File.read full_path
        document[:extension] = format || ""
      else
        document[:blockingError] = 'File Not Found'
      end

      document
    end

    def doc_relative_path(path, format)
      "#{path}.#{format}"
    end

    def doc_full_path(path, format)
      File.join(
        Localdoc::DocTree.root_pathname,
        doc_relative_path(path, format))
    end

    # reader helpers

    def editable_env?
      Rails.env.development?
    end
  end
end
