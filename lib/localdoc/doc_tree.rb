module Localdoc
  module DocTree
    module_function

    def root_pathname
      fail "Set `Localdoc.document_root` to your documents directory." if Localdoc.document_root.nil?
      Pathname.new Rails.root.join(Localdoc.document_root)
    end

    def from_root(url_helpers)
      root = root_pathname
      root_nodes = read_directory_tree(url_helpers, root, name: root)[:children]
      directories, files = root_nodes.partition {|node| node[:isDirectory] }
      root_files = {
        name: "(root)",
        url: path_for_file(url_helpers, root, root),
        children: files,
        isDirectory: true}
      directories << root_files
    end

    def read_directory_tree(url_helpers, pathname, name: nil, strip: nil)
      node = {
        name: name || pathname.to_s,
        url: path_for_file(url_helpers, pathname, strip),
        isDirectory: true,
      }
      node[:children] = children = []

      return node unless pathname.exist?

      pathname.each_child do |entry|
        if entry.directory?
          children << read_directory_tree(
            url_helpers,
            entry,
            name: entry.basename.to_s,
            strip: strip)
        else
          child = {
            name: entry.basename.to_s,
            url: path_for_file(url_helpers, entry, strip),
            children: [],
            isDirectory: false,
          }
          children << child
        end
      end

      node
    end

    def path_for_file(url_helpers, pathname, strip)
      stripped = strip.nil? ? pathname : pathname.relative_path_from(strip)
      url_helpers.show_path stripped
    end
  end
end
