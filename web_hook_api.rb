require 'sinatra'
require 'resque'
require 'json'
require 'yaml'
require 'logger'

set :bind, '0.0.0.0'

SETTINGS ||= YAML.load_file(File.join(Dir.pwd, 'config/config.yml'))

class MultiIO
  def self.delegate_all
    IO.methods.each do |m|
      define_method(m) do |*args|
        ret = nil
        @targets.each { |t| ret = t.send(m, *args) }
        ret
      end
    end
  end

  def initialize(*targets)
    @targets = targets
    MultiIO.delegate_all
  end
end

class AutoDeployment <  Sinatra::Application
  @queue = :deploy
  @logger = Logger.new MultiIO.new(File.open("test.log", 'w'), STDOUT)

  def self.perform(payload)
    @logger.info("payload: #{payload}")

    if payload.nil? or !payload.has_key?('ref')
      @logger.error "invalid payload"
      raise "Invalid Payload"
    end

    branch_name = payload["ref"].split('/').last
    if !SETTINGS.keys.include?(branch_name)
      @logger.debug "invalid log. -- TODO: change this message, make it more meaningful."
      return nil
    end
    perform_deployment(branch_name)
    # notify_users()
  end

  def self.perform_deployment(branch_name)
    @logger.error "perform_deployment"
  	begin
  	  SETTINGS[branch_name].each{ |hash|
        role = hash['role']
        @logger.info("deploying for #{role}")
        system ("bundle exec cap #{role} deploy")
      }
    rescue => ex
      @logger.error(ex.backtrace)
      notify_error
  	end
  end

  def self.notify_users
  end

  def self.notify_error
  end

end

post '/deploy' do
  content_type :json
  Resque.enqueue(AutoDeployment, JSON.parse(request.body.read))
end
