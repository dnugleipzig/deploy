require 'rake'

guard :bundler do
  watch('Gemfile')
end

group :specs, halt_on_fail: true do
  guard :shell do
    def powershell
      %w(
        powershell.exe
        -NoLogo
        -NonInteractive
        -NoProfile
        -ExecutionPolicy Bypass
        -Command
      )
    end

    def single_line(lines)
      lines.each_line.map(&:strip).join(' ')
    end

    def pester(*paths) # rubocop:disable Metrics/MethodLength
      command = <<-EOF
        & {
          Import-Module -Name ./packages/Pester/Pester;
          Invoke-Pester -Path '%s' -EnableExit
        }
      EOF

      paths
        .select { |path| File.exist?(path) }
        .each do |path|
        n path, 'Pester', :pending

        success = RakeFileUtils.sh(*powershell, single_line(command) % path) do |ok, _|
          status = ok ? :success : :failed
          n path, 'Pester', status
          ok
        end

        break unless success
      end

      nil
    end

    watch(%r{^(spec)/.+\.Tests\.ps1$}) do |m|
      spec = m[0]
      all_specs = m[1]

      pester(spec, all_specs)
    end

    watch(%r{^lib/(.+)\.ps(d|m)?1$}) do |m|
      spec = "spec/#{m[1]}.Tests.ps1"
      all_specs = 'spec'

      pester(spec, all_specs)
    end
  end

  guard :rubocop do
    watch('.rubocop.yml') { |m| File.dirname(m[0]) }
    watch(File.basename(__FILE__))
    watch('Gemfile')
    watch('Rules')
    watch(%r{^lib/rules/})
    watch(/\.ru$/)
    watch(/\.rb$/)
    watch(/\.rake$/)
  end
end
