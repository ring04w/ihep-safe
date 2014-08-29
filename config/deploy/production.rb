set :stage, :production

server '202.122.39.231', user: 'deploy', roles: %w{web app db}, my_property: :my_value
