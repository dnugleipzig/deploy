require 'rake/funnel'
require 'rubocop'
require 'rubocop/rake_task'
require 'rubocop/formatter/checkstyle_formatter'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = %w(--format html --out build/lint/rubocop/rubocop.html)

  t.options += if Rake::Funnel::Integration::TeamCity.running?
                 %W(--format #{RuboCop::Formatter::CheckstyleFormatter} --out build/lint/rubocop/rubocop.xml)
               else
                 %w(--format progress)
               end

  # Don't abort rake on failure.
  t.fail_on_error = false

  t.verbose = true
end
