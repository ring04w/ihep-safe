class MachinesController < ApplicationController
  before_action :signed_in_user,only: [:index]

  def index
    #@machines = current_user.machines.paginate(:page => params[:page], :per_page => 5)
    @machines = current_user.machines.need_scan.order("high DESC").paginate(:page => params[:page], :per_page => 5)
  end
  def vulcount
    @machines = Machine.all.order("high DESC").paginate(:page => params[:page], :per_page => 5)
    @LowCount=Result.where(threat:"Low").count()
    @HighCount=Result.where(threat:"High").count()
    @MidCount=Result.where(threat:"Medium").count()
    @chart = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [50, 200, 60, 170]} )
      series = {
               :type=> 'pie',
               :name=> '漏洞数量',
               :data=> [
                  ['高危',  @HighCount],
                  ['中等',     @MidCount],
                  ['低危',    @LowCount]
               ]
      }
      f.series(series)
      f.options[:title][:text] = "漏洞数量概况"
      f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'}) 
      f.plot_options(:pie=>{
        :allowPointSelect=>true,
        :cursor=>"pointer" ,
        :dataLabels=>{
          :enabled=>true,
          :color=>"black",
          :style=>{
            :font=>"20px"
          }
        }
      })
    end
  end

  def show
    @machine = Machine.find(params[:id])
  end

  def startscan
    machine=Machine.find(params[:id])
    if machine.status == "scanning"
      flash[:info]=machine.ip+" already scanning"
    elsif machine.status == "unknown"
      flash[:info]=machine.ip+" can not scan this host"
    else
      machine.status = "scanning"
      #machine.status = "waiting"
      machine.save!
      puts "Enter start"
      puts machine.ip
      flash[:success]=machine.ip+" Start Scan OK"
      ScanWorker.perform_async(machine.ip)
    end
    redirect_to user_machines_path(current_user)
  end

  def viewresult
    machine=Machine.find(params[:id])
    @results=machine.results
  end

  def downloadresult
    machine=Machine.find(params[:id])
    puts machine.ip
    result_path = Rails.root.join('results','html',"#{ machine.ip }.html")
    send_file result_path
  end
end
