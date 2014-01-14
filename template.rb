require File.expand_path('../config.rb', __FILE__)

def gemfile_blank_line
  run 'echo "" >> Gemfile'
end

def create_gemfile
  run 'touch Gemfile'

  add_source 'https://rubygems.org'

  gem 'rails', RAILS_VERSION
  gemfile_blank_line

  gem 'dotenv-rails'
  gem 'mysql2'
  gem 'draper'
  gemfile_blank_line

  gem 'sass-rails'
  gem 'uglifier'
  gem 'coffee-rails'
  gem 'jquery-rails'
  gem 'haml-rails'
  gemfile_blank_line

  gem_group :development, :test do
    gem 'rspec-rails'
    gem 'debugger'
  end

  gem_group :development do
    gem 'better_errors'
    gem 'binding_of_caller'
    gem 'quiet_assets'
  end

  gem_group :test do
    gem 'simplecov'
  end
  run 'sed -i "" "s/\"/\'/g" Gemfile'
end

def install_bundle
  run 'bundle install'
end

def add_env_example
  dummy_key = '56efe3a3f796fe636d9427c8d2db3477e50032c6d04a4824a4bcdd109b7d316ed6c208b50e19feea16457c507e42805d733fa842a9835d61dc61fa590cb5aa3e'
  run 'cp config/database.yml config/database.yml.example'
  run %q{sed -i "" "s/secret_key_base = '.*'/secret_key_base = ENV['RAILS_SECRET_KEY_BASE']/g" config/initializers/secret_token.rb}
  run %Q{echo "RAILS_SECRET_KEY_BASE: '#{dummy_key}'" > .env.example}
  run 'cp .env.example .env'
end

def cleanup_configuration
  run 'sed -i "" "s/\"/\'/g" config/environments/test.rb'
  run 'sed -i "" "s/\"/\'/g" config/application.rb'
  run 'sed -i "" "/# require/d" config/application.rb'
end

def create_gitignore
  run "cat << EOF >> .gitignore
/.bundle
/.env
/.env.production
/config/database.yml
/coverage
/doc
/log/*.log
/public/assets
/vendor/bundle
/tmp
EOF"
end

def use_haml_layout
  run 'rm app/views/layouts/application.html.erb'
  run "cp #{FILES_DIR}/app/views/layouts/application.html.haml app/views/layouts/application.html.haml"
  run %q{sed -i "" "s/AppName/`cat config/application.rb|grep module|awk '{print $2}'`/g" app/views/layouts/application.html.haml}
end

def add_home_index
  run 'rails g controller home index --skip-assets --skip-decorator --skip-helper --skip-view-specs'
  run 'sed -i "" "/home\/index/d" config/routes.rb'
  route "root to: 'home#index'"
  run 'sed -i "" "s/\"returns http success\"/\'returns http success\'/g" spec/controllers/home_controller_spec.rb'
end

def add_readme_md
  run 'rm README.rdoc'
  run 'touch README.md'
end

def remove_turbolinks
  run 'sed -i "" "/require turbolinks/d" app/assets/javascripts/application.js'
  run 'sed -i "" "s/, \"data-turbolinks-track\" => true//g" app/views/layouts/application.html.erb'
end

def use_application_scss
  run 'mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss'
  run 'sed -i "" /require_tree/d app/assets/stylesheets/application.css.scss'
end

def remove_js_require_tree
  run 'sed -i "" /require_tree/d app/assets/javascripts/application.js'
end

def install_rspec
  run 'rails g rspec:install'
  run "cp #{FILES_DIR}/spec/spec_helper.rb spec/spec_helper.rb"
end

def add_ruby_version
  run "echo '#{RBENV_RUBY_VERSION}' > .ruby-version"
end

def run_db_create_migrate
  rake 'db:create db:migrate'
end

def setup_git
  git :init
  git add: '.'
  git commit: "-m 'Initial commit'"
end

create_gemfile
install_bundle

add_env_example
cleanup_configuration
create_gitignore
add_readme_md

use_haml_layout
add_home_index
remove_turbolinks

use_application_scss
remove_js_require_tree
install_rspec
add_ruby_version
run_db_create_migrate
setup_git
