require 'rake/funnel'

module RSpec
  module SimpleCov
    class TeamCityServiceMessageFormatter
      include Rake::Funnel::Integration::TeamCity

      # Prints the {https://confluence.jetbrains.com/display/TCD9/Build+Script+Interaction+with+TeamCity#BuildScriptInteractionwithTeamCity-ReportingBuildStatus TeamCity service message}.
      def format(result)
        ServiceMessages.build_status(text: "{build.status.text}, Code Coverage #{result.covered_percent.round(2)}%")
      end
    end
  end
end
