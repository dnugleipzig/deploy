# frozen_string_literal: true

require 'rake/funnel'
require 'rubocop'
require 'rubocop/rake_task'
require 'rubocop/formatter/checkstyle_formatter'

desc 'Run RuboCop'
task :rubocop do
  namespace :rubocop do
    rubocop = RuboCop::RakeTask.new(:rubocop) do |t|
      t.options = %w(--format html --out build/rubocop/rubocop.html)

      t.options += if Rake::Funnel::Integration::TeamCity.running?
                     %W(
                       --format #{RuboCop::Formatter::CheckstyleFormatter}
                       --out build/rubocop/rubocop.xml
                     )
                   else
                     %w(--format progress)
                   end

      t.fail_on_error = true
      t.verbose = true
    end

    begin
      Rake::Task[rubocop.name].execute
    ensure
      Rake::Funnel::Integration::TeamCity::ServiceMessages
        .publish_artifacts('build/rubocop/**/*.html => rubocop')

      Rake::Funnel::Integration::TeamCity::ServiceMessages
        .import_data(type: :checkstyle,
                     path: 'build/rubocop/rubocop.xml')
    end
  end
end
