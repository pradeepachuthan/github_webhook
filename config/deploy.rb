require 'capistrano/version'
require 'rubygems'
require 'yaml'
require 'capistrano/rvm'
#require 'capinatra'
load 'deploy' if respond_to?(:namespace) # cap2 differentiator

# app settings
set :app_file, "web_hook_api.rb"
set :application, "demo"
set :domain, "52.35.114.16"
set :rvm_ruby_version, '2.1.2' 

role :app, domain
role :web, domain
role :db,  domain, :primary => true

# general settings
set :user, "ubuntu"
set :use_sudo, false
set :deploy_to, "/var/www/papricek/#{application}"
#set :deploy_via, :remote_cache

# scm settings
set :repository, "https://github.com/pradeepachuthan/github_webhook.git"
set :scm, "git"
set :scm_passphrase, ""
set :scm_verbose, true
set :branch, "master"
#set :git_enable_submodules, 1



namespace :deploy do
  task :restart do
    p "Executing restarting"
    run "cd #{deploy_to}/current/ && bundle install"
    run "if [ -f #{unicorn_pid} ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf}  -D; fi"
  end
  task :start do
    p "Executing start"
    run "cd #{deploy_to}/current/ && bundle exec unicorn -c #{unicorn_conf} -D"
  end
  task :stop do
    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
end




