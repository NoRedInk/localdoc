namespace :localdoc do
  desc "Compile assets"
  task webpack: :environment do
    Dir.chdir(Localdoc::Engine.root) do
      sh 'webpack'
    end
  end
end

Rake::Task['assets:precompile'].enhance ['localdoc:webpack']
