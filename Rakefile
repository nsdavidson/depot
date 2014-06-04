# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'aws-sdk-core'


Depot::Application.load_tasks

Aws.config[:region] = 'us-east-1'

task :build_dev do
  cfn = Aws::CloudFormation.new
  template = File.read("depot-dev.template")
  cfn.create_stack(stack_name: "depot-dev", template_body: template)
  print "Waiting for CloudFormation stack to build"
  until !cfn.describe_stacks(stack_name: "depot-dev").first[0][0].stack_status.include?("CREATE_IN_PROGRESS") do
    print "."
    sleep 15
  end
  puts "\n"
  puts "CloudFormation stack is complete..."
  outputs = cfn.describe_stacks(stack_name: "depot-dev").first[0][0].outputs
  outputs.each do |op|
    puts "#{op.output_key} = #{op.output_value}"
    ENV["#{op.output_key}"] = op.output_value
  end

  puts ENV["URL"]
end

task :test_dev do
  puts File.read(aws_config.txt, 'w') 
end

task :test_value_set do
  ENV["URL"] = "http://example.org"
end

task :test_value_get do
  puts ENV["URL"]
end