require 'net/http'
require 'json'
require 'erb'
require 'yaml'
require 'optparse'

module Netatmo
  class Token
    @@url = 'https://api.netatmo.com/oauth2/token'

    def initialize(client_id, client_secret, refresh_token, scope='read_station', grant_type='refresh_token')
      @client_id = client_id
      @client_secret = client_secret
      @refresh_token = refresh_token
      @grant_type = grant_type
      @scope = scope

      auth_refresh_token
    end

    def auth_refresh_token
      res = Net::HTTP.post_form(
        URI(@@url), {
          'grant_type' => @grant_type,
          'client_id' => @client_id,
          'client_secret' => @client_secret,
          'refresh_token' => @refresh_token,
          'scope' => @scope
        }
      )
      raise "login failed: #{res.body}" unless res.is_a?(Net::HTTPSuccess)

      data = JSON.parse(res.body)
      raise 'API did not return access_token' unless data.key?('access_token')

      @token = data['access_token']
    end

    def to_s
      @token
    end
  end

  class Station
    @@url = 'https://api.netatmo.com/api/getstationsdata'

    attr_accessor :data, :token, :id, :filter

    def include_station_name?
      !!@include_station_name
    end

    def initialize(token, id, include_station_name = true)
      @token = token
      @id = id
      @include_station_name = include_station_name
    
      update_data
    end

    def update_data
      uri = URI(@@url)
      params = { access_token: @token, device_id: @id }
      uri.query = URI.encode_www_form(params)
      res = Net::HTTP.get_response(uri)
      raise "error updating station data: #{res.body}" unless res.is_a?(Net::HTTPSuccess)

      @data = JSON.parse(res.body)
    end

    def to_s
      @data.to_json
    end

  end

  class App
    attr_reader :config_file, :config

    def parse_options
      OptionParser.new do |opts|
        opts.banner = 'Usage: netatmo [options]'

        opts.on('-cPATH', '--config=PATH', 'Path to configuration file') do |c|
          @config_file = c
        end
      end.parse!
    end

    def initialize
      @config_file = '/etc/netatmo/netatmo.yml'
      parse_options
      @config = Config.load_file(config_file)
    end

    def run
      puts station.update_data.to_json
    end

    def token
      Netatmo::Token.new(
        config.client_id,
        config.client_secret,
        config.refresh_token
      )
    end

    def station
      include_station_name = true
      include_station_name = config.include_station_name \
        if config.key? 'include_station_name'
      Netatmo::Station.new(token, config.device_id, include_station_name)
    end
  end

  class Config < Hash
    class MissingSetting < StandardError; end

    attr_accessor :file

    def self.load_file(file)
      raw = File.read(file)
      content = ERB.new(raw).result
      hash = YAML.safe_load(content, aliases: true).to_hash

      config = new
      config.merge!(hash)
      config.file = file
      config
    end

    def method_missing(name, *_args, &_block)
      unless key? name.to_s
        raise(
          MissingSetting,
          "No setting for #{name} in #{file}"
        )
      end

      fetch(name.to_s)
    end
  end
end

Netatmo::App.new.run