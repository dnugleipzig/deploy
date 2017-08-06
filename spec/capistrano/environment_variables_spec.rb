require 'capistrano/environment_variables'

describe EnvironmentVariables do
  let(:vars) do
    {
      'DEPLOY_ENV_FOO' => 42,
      'DEPLOY_ENV_BAR' => 23,
      'BAR' => 123
    }
  end

  it 'extracts all variables matching ' + described_class::PREFIX.to_s do
    expect(described_class.extract(vars)).to eq('FOO' => 42, 'BAR' => 23)
  end
end
