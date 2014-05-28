require "rexml/document"
include REXML

class ScanWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def analysis_report(ip)
    machine=Machine.find_by(ip:ip)
    machine.results.clear
    doc = Document.new(File.new(Rails.root.join('data',ip+'.xml')))
    report = doc.root[0][0]
    machine.high=XPath.match(report,"result_count/hole/filtered").map { |x| x.text}
    machine.mid=XPath.match(report,"result_count/warning/filtered").map { |x| x.text}
    machine.low=XPath.match(report,"result_count/info/filtered").map { |x| x.text}
    machine.status="scanned"
    machine.save!
    report.elements.each("results/result") do |e|
      port=XPath.first(e,"port").text
      threat=XPath.first(e,"threat").text
      description=XPath.first(e,"description").text[0..2000]
      xref=XPath.first(e,"nvt/xref").text
      result=Result.create(port:port,threat:threat,xref:xref,description:description)
      machine.results << result
    end

  end

  def perform(ip)
    path_to_script=File.dirname(__FILE__)
    openvas_ip_1=ENV['OPENVAS_IP_1']
    openvas_password=ENV['OPENVAS_PASSWORD']
    puts path_to_script,openvas_ip_1,openvas_password
    #system "python #{path_to_script}/run.py #{openvas_ip_1} 'admin' #{openvas_password} #{ip}"
    if File.exist?(Rails.root.join('data',ip+'.xml')) then
      analysis_report(ip)
    end
  end

end
