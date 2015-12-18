
require 'sinatra'
require 'resque'
require 'json'
require 'yaml'

set :bind, '0.0.0.0'

SETTINGS ||= YAML.load_file(File.join(Dir.pwd, 'config/config.yml'))
logger = Logger.new File.new('/var/log/deploy.log', 'w')




class AutoDeployment <  Sinatra::Application
  @queue = :deploy

  def self.perform(payload)
    logger.info("payload: #{payload}")

    raise "Invalid Payload" if payload.nil? or !payload.has_key?('ref')

    branch_name = payload["ref"].split('/').last
    return nil unless SETTINGS.keys.include?(branch_name)
    perform_deployment(branch_name)
    # notify_users()
  end

  def self.perform_deployment(branch_name)
  	begin
  	  SETTINGS[branch_name].each{ |hash|
        role = hash['role']
        logger.info("deploying for #{role}")
        # system ("bundle exec cap #{role} deploy")
      } 
    rescue => ex
      logger.error(ex.backtrace)
      notify_error
  	end
  end

  def self.notify_users
  end

  def self.notify_error
  end

end

post '/deploy' do
  logger.info("got a new request.")
  content_type :json
  Resque.enqueue(AutoDeployment, JSON.parse(request.body.read))
  # AutoDeployment.update(request.body.read)
end
