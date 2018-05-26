# frozen_string_literal: true

desc 'Run lints'
task lint: %i(rubocop ps_script_analyzer)
