lock '3.2.1'

set :application, 'ihep-safe'
set :repo_url, "git@github.com:wcc526/#{fetch(:application)}.git"

set :deploy_to, '/var/www/my_app'

set :linked_files, %w{config/database.yml config/application.yml}
set :linked_dirs, %w{results bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
  after :finishing, :cleanup

  desc "Makes sure local git is in sync with remote."
  task :check_revision do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
      exit
    end
  end

  %w[start stop restart].each do |command|
  desc "#{command} Unicorn server."
    task command do
      on roles(:app) do
        execute "/etc/init.d/unicorn_init #{command}"
      end
    end
  end


  before :deploy, "deploy:check_revision"
  after :deploy, "deploy:restart"
  after :rollback, "deploy:restart"

end

namespace :setup do

  desc "Upload database.yml file."
  task :upload_yml do
    on roles(:app) do
      upload! "config/database.yml", "#{shared_path}/config/database.yml",via: :scp
      upload! "config/application.yml", "#{shared_path}/config/application.yml",via: :scp
    end
  end

  desc "SCP transfer scan results to the shared folder"
  task :upload_dir do
    on roles(:app) do
      upload! "results", "#{shared_path}/", via: :scp, recursive: true
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
after  "deploy:finishing","setup:seed_db"
