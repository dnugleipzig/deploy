# rubocop:disable Metrics/BlockLength

namespace :download do
  desc 'Download Web Platform Installer'
  task :webpi, [:executable] do |_t, args|
    on release_roles(:all) do |host|
      webpi = args[:executable]

      next if test("[ -f #{webpi.shellescape} ]")

      begin
        url = 'http://download.microsoft.com/download/C/F/F/CFF3A0B8-99D4-41A2-AE1A-496C08BEB904/WebPlatformInstaller_x86_en-US.msi'
        msi = capture(:mktemp, '--suffix', '-webpi.msi')
        extracted = capture(:mktemp, '--directory', '--suffix', '-webpi.msi')
        extracted_win = capture(:cygpath, '--windows', '--absolute', extracted.shellescape)

        within(File.dirname(msi)) do
          execute :wget,
                  url.shellescape,
                  '--no-verbose',
                  '--output-document',
                  msi.shellescape

          execute :chmod, '775', msi.shellescape
          execute :chmod, '777', extracted.shellescape

          execute :msiexec,
                  '/a',
                  File.basename(msi).shellescape,
                  '/qn',
                  "TARGETDIR=\"#{extracted_win.shellescape}\""

          execute :cp,
                  '-r',
                  File.join(extracted, 'Microsoft/Web Platform Installer/.').shellescape,
                  File.join(File.dirname(webpi)).shellescape

          unless test("[ -f #{webpi.shellescape} ]")
            error "Web Platform installer is not available in path #{webpi} on #{host}"
            exit 1
          end
        end
      ensure
        # rubocop:disable Style/RescueModifier
        execute :rm, '-f', msi.shellescape rescue nil
        execute :rm, '-rf', extracted.shellescape rescue nil
        # rubocop:enable Style/RescueModifier
      end
    end
  end
end
