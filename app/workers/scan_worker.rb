class ScanWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(ip)
    print ip+"Second Start scan"
    path_to_script=File.dirname(__FILE__)
    openvas_ip_1=ENV['OPENVAS_IP_1']
    openvas_password=ENV['OPENVAS_PASSWORD']
    system "python #{path_to_script}/run.py #{openvas_ip_1} 'admin' #{openvas_password} #{ip}"
  end
end
