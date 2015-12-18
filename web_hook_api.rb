
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
    @logger.info("payload: #{branch_name}")
    @logger.info("Available branch names in Settings keys: #{SETTINGS.keys}")
    if !SETTINGS.keys.include?(branch_name)
      @logger.debug "invalid log. -- TODO: change this message, make it more meaningful."
      return nil
    end
    perform_deployment(branch_name)
    # notify_users()
  end

  def self.perform_deployment(branch_name)
    @logger.error "perform_deployment"

    transportify_home = "/home/ubuntu/transportify"

  	begin
  	  SETTINGS[branch_name].each{ |hash|
        role = hash['role']
        deploy_file = hash['deploy_path']
        config_file = hash['config_path']
        config_filename = config_file.split("/").last

        @logger.info("deploying for #{role}")
        system ("cd #{transportify_home} && git stash && git stash clear && git pull && git checkout #{branch_name}")

        @logger.info("remove existing config files")
        system("rm -rf #{transportify_home}/config/deploy.rb")
        system("rm -rf #{transportify_home}/config/deploy/*")

        @logger.info("copy required config files")
        system("cp #{deploy_file} #{transportify_home}/config/deploy.rb ")
        system("cp #{config_file} #{transportify_home}/config/deploy/#{config_filename} ")

        @logger.info("lets start actual deployment now.")
        system ("cd #{transportify_home} && bundle exec cap #{role} deploy")
        && bundle exec cap #{role} deploy")
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
  # Resque.enqueue(AutoDeployment, JSON.parse(request.body.read))
  AutoDeployment.perform(JSON.parse(request.body.read))
end
