# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Depot::Application.load_tasks

require 'aws-sdk-core'

Aws.config[:region] = 'us-east-1'

task :build_dev do
  cfn = Aws::CloudFormation.new
  template = File.read("depot-dev.template")
  cfn.create_stack(stack_name: "depot-dev", template_body: template)
end