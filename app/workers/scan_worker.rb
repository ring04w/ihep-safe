require "rexml/document"
include REXML

class ScanWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

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

  def perform(ip)
    path_to_script=File.dirname(__FILE__)
    openvas_ip=ENV['OPENVAS_IP']
    openvas_password=ENV['OPENVAS_PASSWORD']
    openvas_result_dir=Rails.root.join('results')
    openvas_result_path=Rails.root.join('results','xml',ip+'.xml')
    system "python #{path_to_script}/run.py #{openvas_ip} 'admin' #{openvas_password} #{ip} #{openvas_result_dir}"
    if File.exist?(openvas_result_path) then
      analysis_report(Machine.find_by(ip:ip),openvas_result_path)
    end
  end

end
