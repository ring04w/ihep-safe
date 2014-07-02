# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'ihep-safe'
set :repo_url, 'git@github.com:wcc526/ihep-safe.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/apps/my_project'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/application.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{results bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

namespace :setup do

  desc "SCP transfer figaro configuration to the shared folder"
    task :upload_yml do
      on roles(:app) do
        upload! "config/application.yml", "#{shared_path}/config/application.yml", via: :scp
      end
  end

  desc "SCP transfer scan results to the shared folder"
    task :upload_results do
      on roles(:app) do
        upload! "results", "#{shared_path}/results", via: :scp, recursive: true
      end
  end

  desc "Seed the database."
      task :seed_db do
        on roles(:app) do
          within "#{current_path}" do
          with rails_env: :production do
          execute :rake, "db:seed"
        end
      end
    end
  end

  desc "ipdb sync"
      task :ipdb_sync do
        on roles(:app) do
          within "#{current_path}" do
          with rails_env: :production do
          execute :rake, "ipdb:sync"
        end
      end
    end
  end

  desc "ipdb scan"
      task :ipdb_scan do
        on roles(:app) do
          within "#{current_path}" do
          with rails_env: :production do
          execute :rake, "ipdb:scan"
        end
      end
    end
  end

end

before "deploy:check:linked_files", "setup:upload_yml"
