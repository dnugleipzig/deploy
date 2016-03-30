require 'inwx/domrobot'
require 'capistrano/cacerts'

module DNS
  class Inwx
    def initialize(config, api_endpoint = 'api.domrobot.com')
      @user = with_env_token(config['user'])
      @password = with_env_token(config['password'])
      @records = config.fetch('records', [])
      @api_endpoint = api_endpoint
    end

    def run
      @records.each do |record|
        ensure_record(record)
      end
    end

    private

    ENV_TOKEN = %r{^env://}

    def with_env_token(value)
      return value unless value =~ ENV_TOKEN

      ENV[value.sub(ENV_TOKEN, '')]
    end

    def ensure_record(record) # rubocop:disable Metrics/MethodLength
      query = query(record)

      puts "Ensuring RR #{query} exists"
      find_managed_domain(query['domain'])

      if match = exact_match(query) # rubocop:disable Lint/AssignmentInCondition
        warn "RR found: #{match}"
      elsif match = name_type_match(query) # rubocop:disable Lint/AssignmentInCondition
        warn "RR found, updating: #{match}"
        update_record(match['id'], query)
      else
        warn "Creating RR: #{query}"
        create_record(query)
      end
    end

    def split_domain_hostname(address)
      parts = address.split('.')

      hostname = parts[0...-2].join('.')
      domain = parts.last(2).join('.')

      [domain, hostname]
    end

    def robot
      @robot ||= begin
        robot = INWX::Domrobot.new(@api_endpoint)
        robot.client.http.ca_file = CACerts.path

        puts "Logging in as #{@user} on #{@api_endpoint}"
        robot.login(@user, @password)
        robot
      end
    end

    def logout
      puts 'Logging out'
      robot.logout
    end

    def exact_match(query)
      records(query)
    end

    def name_type_match(query)
      query_with = %w(domain name type)
      records(query.dup.keep_if { |key, _| query_with.include?(key) })
    end

    def query(record)
      domain, hostname = split_domain_hostname(record['name'])

      record.merge('domain' => domain, 'name' => hostname)
            .reject { |_, value| value.nil? }
            .tap { |h|
              h['type'] = h['type'].upcase if h['type'].respond_to?(:upcase)
            }
    end

    def records(query)
      result = robot.call('nameserver', 'info', query)
      records = result.fetch('resData', {}).fetch('record', [])

      records.first
    end

    def find_managed_domain(domain)
      domains = robot.call('nameserver', 'list', domain: domain)
      if domains.fetch('resData', {}).fetch('count', 0) == 0
        raise(ArgumentError, "Domain #{domain} is not managed by this account")
      end
    end

    def create_record(info)
      result = robot.call('nameserver', 'createRecord', info)

      raise(ArgumentError, result.inspect) if result['code'] != 1000
    end

    def update_record(id, info)
      info = info.dup.reject { |key, _| key == 'domain' }
      info['id'] = id

      result = robot.call('nameserver', 'updateRecord', info)

      raise(ArgumentError, result.inspect) if result['code'] != 1000
    end
  end
end
