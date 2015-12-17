require './web_hook_api'
require 'resque/tasks'

task "resque:setup" do
    ENV['QUEUE'] = '*'
end

desc "Alias for resque:work"
task "jobs:work" => "resque:work"
