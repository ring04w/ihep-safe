require "rexml/document"
include REXML

namespace :ipdb do
  desc "sync"
  task sync: :environment do
    time = Benchmark.measure do
      Rake::Task["db:reset"].invoke
      VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
      client = Mysql2::Client.new(host:"202.122.39.231", username:"root",password:ENV['IPDB_DATABASE_PASSWORD'],database:"sec")
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

  desc "scan"
  task scan: :environment do

    def analysis_report(machine,report_path)
      doc = Document.new(File.new(report_path))
      report = doc.root[0][0]
      high=REXML::XPath.match(report,"result_count/hole/filtered").map { |x| x.text}
      machine.high=high[0]
      mid=REXML::XPath.match(report,"result_count/warning/filtered").map { |x| x.text}
      machine.mid=mid[0]
      low=REXML::XPath.match(report,"result_count/info/filtered").map { |x| x.text}
      machine.low=low[0]
      machine.status="scanned"
      machine.save!
      report.elements.each("results/result") do |e|
        port=REXML::XPath.first(e,"port").text
        threat=REXML::XPath.first(e,"threat").text
        description=REXML::XPath.first(e,"description").text
        if description then
          description=description[0..2000]
        end
        xref=REXML::XPath.first(e,"nvt/xref").text
        result=Result.create(port:port,threat:threat,xref:xref,description:description)
        machine.results << result
      end

    end

    machines=Machine.all
=begin
    t= File.open( Rails.root.join('tmp','scanip'),"w")
    machines.each do |machine|
      t << machine.ip+"\n"
    end
    t.close
    ip = File.open(Rails.root.join('tmp','scantmp'),"w")
    ip.close
    system "nmap -T5 -F -iL #{t.path} -oG #{ip.path}"
    File.open(ip.path).each do |line|
      line=line.split(' ')
      if line[3]=="Ports:" && line[3].include?('open') then
        machine=Machine.find_by(ip:line[1])
        machine.status="waiting"
        machine.save!
      end
    end
=end
    machines.each do |machine|
      report_path=Rails.root.join('results','xml',machine.ip+'.xml')
      if File.exist?(report_path) then
        analysis_report(machine,report_path)
      end
    end
  end

end
