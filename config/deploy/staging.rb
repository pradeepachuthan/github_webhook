# capistrano will use this user to perform actions
set :user, "taxipixi"

# branch that is going to be used to deploy release. You may set it from console: cap deploy -s branch=_branch_name
set :branch, fetch(:branch, "demo")

set :rails_env, "staging"

server '52.30.61.166', :app, :web, :db, :primary => true

# ssh options
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:auth_methods] = ["publickey"]
# it is not wise to store amazon key in repository. You need to get it from instance owner and set path to it here
ssh_options[:keys] = ["#{ENV['PWD']}/config/amazon_keys/zip_go_dev.pem"]
set :rsync_cmd, "rsync -rave 'ssh -i #{ENV['PWD']}/config/amazon_keys/zip_go_dev.pem'"
