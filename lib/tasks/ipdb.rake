namespace :ipdb do
  desc "sync"
  task sync: :environment do
    time = Benchmark.measure do
      Rake::Task["db:reset"].invoke
      VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
      client = Mysql2::Client.new(host:"192.168.254.9", username:"root",password:ENV['IPDB_DATABASE_PASSWORD'],database:"sec")
      results = client.query("select * from secinfo;");
      emailip=Hash.new
      results.each do |hash|
        if hash['email'] and hash['ip'] and (hash['email'].end_with? '@ihep.ac.cn')
            email=hash['email'].strip.downcase
            ip=hash['ip'].strip
            if !((email =~ VALID_EMAIL_REGEX) and (ip =~ Resolv::IPv4::Regex )) then
              next
            end
            emailip[email] ||= []
            emailip[email] << ip
        end
      end
      emailip.each do |k,v|
          if (k=='wengcc@ihep.ac.cn') then
            user=User.create(email:k,role:2)
          else
            user=User.create(email:k)
          end
          v.each do |ip|
            Machine.create(ip:ip,user:user)
          end
      end
    end
    puts time
  end

end
