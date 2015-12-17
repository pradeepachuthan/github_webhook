# define paths and filenames
deploy_to = "/home/ubuntu"
rails_root = "#{deploy_to}/current"
working_directory rails_root

pid_file = "#{deploy_to}/shared/pids/unicorn.pid"
socket_file= "#{deploy_to}/shared/unicorn.sock"
log_file = "#{rails_root}/log/unicorn.log"
err_log = "#{rails_root}/log/unicorn_error.log"
old_pid = pid_file + '.oldbin'

timeout 30
worker_processes 2 # increase or decrease
listen socket_file, :backlog => 1024

pid pid_file
stderr_path err_log
stdout_path log_file

# make forks faster
preload_app true

# make sure that Bundler finds the Gemfile
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = File.expand_path('Gemfile', File.dirname(__FILE__))
end
