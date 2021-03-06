# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'aws-sdk-core'
require 'net/http'
require 'uri'


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
    File.open('url.txt', 'w') { |file| file.write(op.output_value)}
  end
  puts File.read("url.txt")
end

task :build_qa do
  cfn = Aws::CloudFormation.new
  template = File.read("depot-dev.template")
  cfn.create_stack(
    stack_name: "depot-qa",
    template_body: template,
    parameters: [
      {
        parameter_key: "WebServerInstanceCount",
        parameter_value: "2"
      },
      {
        parameter_key: "AppServerInstanceCount",
        parameter_value: "2"
      }
    ]
  )
  print "Waiting for CloudFormation stack to build"
  until !cfn.describe_stacks(stack_name: "depot-qa").first[0][0].stack_status.include?("CREATE_IN_PROGRESS") do
    print "."
    sleep 15
  end
  puts "\n"
  puts "CloudFormation stack is complete..."
  outputs = cfn.describe_stacks(stack_name: "depot-qa").first[0][0].outputs
  outputs.each do |op|
    puts "#{op.output_key} = #{op.output_value}"
    File.open('url.txt', 'w') { |file| file.write(op.output_value)}
  end
  puts File.read("url.txt")
end

task :test_dev do
  sleep 90
  url_to_test = File.read("url.txt")
  puts "URL to test: #{url_to_test}"
  uri = URI.parse(url_to_test)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)

  counter = 0
  print "Waiting for environment to become available..."
  until http.request(request).code == "200" or counter > 900 do
    print '.'
    sleep 30
    counter += 30
  end

  if counter < 900
    puts "\n"
    puts "Environment is now available at #{url_to_test}"
  else
    puts "\n"
    puts "Environment has timed out.  Deleting stack."
    cfn = Aws::CloudFormation.new
    cfn.delete_stack(stack_name: "depot-dev")
  end
end

task :teardown_dev do
  puts "Tearing down dev environment..."
  cfn = Aws::CloudFormation.new
  cfn.delete_stack(stack_name: "depot-dev")
  until cfn.describe_stacks(stack_name: "depot-dev").count == 0 do
    sleep 5
  end
  puts "CloudFormation and all resources destroyed"
end

