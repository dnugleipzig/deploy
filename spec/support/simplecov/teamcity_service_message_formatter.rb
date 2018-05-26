# frozen_string_literal: true

require 'rake/funnel'

module Spec
  module Support
    module SimpleCov
      # {::SimpleCov} formatter that prints a
      # {https://confluence.jetbrains.com/display/TCD9/Build+Script+Interaction+with+TeamCity#BuildScriptInteractionwithTeamCity-ReportingBuildStatus
      # TeamCity service message}
      # containing the coverage percentage.
      class TeamCityServiceMessageFormatter
        include Rake::Funnel::Integration::TeamCity

        # Prints the
        # {https://confluence.jetbrains.com/display/TCD9/Build+Script+Interaction+with+TeamCity#BuildScriptInteractionwithTeamCity-ReportingBuildStatus
        # TeamCity service message}.
        def format(result)
          ServiceMessages.build_status(text: "{build.status.text}, Code Coverage #{result.covered_percent.round(2)}%")
        end
      end
    end
  end
end
