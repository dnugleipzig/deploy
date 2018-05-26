# frozen_string_literal: true

namespace :download do
  desc 'Download NuGet'
  task :nuget, [:executable] do |_t, args|
    on release_roles(:all) do
      nuget = args[:executable]

      next if test("[ -f #{nuget.shellescape} ]")

      execute :mkdir,
              '--parents',
              File.dirname(nuget).shellescape

      execute :wget,
              'https://www.nuget.org/nuget.exe',
              '--no-verbose',
              '--output-document',
              nuget.shellescape

      unless test("[ -f #{nuget.shellescape} ]")
        error "NuGet is not available in path #{nuget} on #{host}"
        exit 1
      end
    end
  end
end
