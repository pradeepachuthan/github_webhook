require 'sinatra'

require 'json'
require 'yaml'

set :bind, '0.0.0.0'

SETTINGS ||= YAML.load_file(File.join(Dir.pwd, 'config/config.yml'))

class AutoDeployment <  Sinatra::Application
  
  def self.update(json_params)
    puts "123 Inside update itesthowing"
    request_payload = JSON.parse(File.read('payload.json'))
    if request_payload.nil? or !request_payload.has_key?('ref')
      raise "Invalid Payload"
    else
    branch_name = request_payload["ref"].split('/').last
    return nil unless SETTINGS.keys.include?(branch_name)
      perform_deployment(branch_name)
    # notify_users(SETTINGS["#{branch_name}"].each { |hash| notify_users(hash[:notify]) })
    end
  end

  def self.perform_deployment(branch_name)
  	begin
  	  SETTINGS["#{branch_name}"].each{ |hash| system ("bundle exec cap #{hash[:role]} deploy") } 
    rescue => ex
  	  env['rack.errors'].puts ex
  	end
  end

  def self.notify_users(emails_array)
    
  end

end

post '/deploy' do
  p "before updating"
  AutoDeployment.update(request.body.read)
end
