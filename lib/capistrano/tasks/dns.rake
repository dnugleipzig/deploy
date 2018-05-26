# frozen_string_literal: true

namespace :dns do
  task :setup, [:config] do |_t, args|
    next if dry_run?

    DNS.setup(args[:config])
  end
end
