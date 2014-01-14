#!/usr/bin/env ruby
if __FILE__ == $PROGRAM_NAME
  unless ARGV.length == 1
    puts 'Pass rails app name'
    exit(1)
  end

  require File.expand_path('../config.rb', __FILE__)

  project_name = ARGV.first
  template_path = File.expand_path('../template.rb', __FILE__)
  options = %w(
    --database=mysql
    --no-rc
    --skip-bundle
    --skip-gemfile
    --skip-git
    --skip-keeps
    --skip-test-unit
  ).join(' ')
  options << " --template=#{template_path}"
  system 'mkdir -p out'
  system "rails _#{RAILS_VERSION}_ new out/#{project_name} #{options}"
end
