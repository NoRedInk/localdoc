class TaskActionView < ActionView::Base
 def protect_against_forgery?
   false
 end
end

namespace :localdoc do
  desc "Compile assets"
  task webpack: :environment do
    Dir.chdir(Localdoc::Engine.root) do
      sh 'npm install'
      sh 'npm run webpack'
    end
  end

  namespace :static do
    desc 'Generate static site in ./localdoc_static/ directory'
    task generate: :environment do |_t, args|
      out_dir = args[:out] || 'localdoc_static'

      url_helpers = Localdoc::Engine.routes.url_helpers
      tree = Localdoc::DocTree.from_root(url_helpers, file_suffix: '.html')
      root_node = tree.find {|node| node[:isRoot] }
      script_name = Pathname.new root_node[:url]

      ActionController::Base.config.relative_url_root = script_name.to_s
      controller = ActionController::Base.new
      controller.request = ActionDispatch::TestRequest.new

      view_options = {
        file: 'localdoc/application/show',
        layout: 'layouts/localdoc/application',
      }

      js_path = 'localdoc/bundle.js'
      # executing webpack as this task's dependency doesn't work:
      # Rails.application.assets doesn't pick up the generated javascript file
      fail 'Run rake localdoc:webpack first' unless Rails.application.assets[js_path]

      FileUtils.mkdir_p out_dir
      Dir.chdir(out_dir) do
        # copy assets (hardcoding file path for now)
        full_js_path = File.join('.', script_name, 'assets', js_path)
        FileUtils.mkdir_p File.dirname(full_js_path)
        FileUtils.cp(Rails.application.assets[js_path].pathname, full_js_path)

        # render html
        Localdoc::DocTree.walk_nodes(tree) do |node|
          if !node[:isDirectory] || node[:isRoot]
            filename = File.basename(node[:url], '.html')
            extname = File.extname(filename)
            path = Pathname.new(File.join(
                                 File.dirname(node[:url]),
                                 File.basename(filename, extname)))
            path_info = path.relative_path_from(script_name).to_s

            rel_path = File.join('.', node[:url])
            html_path =
              if node[:isRoot]
                File.join(rel_path, 'index.html')
              else
                rel_path
              end

            page_data = Localdoc::Api.show_page_data(
              url_helpers,
              path_info,
              extname.sub('.', ''),
              file_suffix: '.html',
              editable: false)
            assigns = {page_data: page_data}
            view = TaskActionView.new(
              ActionController::Base.view_paths, assigns, controller)
            html = view.render(view_options)

            FileUtils.mkdir_p File.dirname(html_path)
            open(html_path, 'w') do |f|
              f.write(html)
            end
            puts Pathname.new(File.join(out_dir, html_path)).cleanpath
          end
        end
      end
    end
  end
end

Rake::Task['assets:precompile'].enhance ['localdoc:webpack']
