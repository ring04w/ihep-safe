set :stage, :production

server '11.11.11.11', user: 'deploy', roles: %w{web app db}, my_property: :my_value
