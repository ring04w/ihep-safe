class MachinesController < ApplicationController
  before_action :signed_in_user,only: [:index]

  def index
    #@machines = current_user.machines.paginate(:page => params[:page], :per_page => 5)
    @machines = current_user.machines.need_scan.order("high DESC").paginate(:page => params[:page], :per_page => 5)
  end
  def all
    #@machines = Machine.all.order("high DESC").paginate(:page => params[:page], :per_page => 5)
    @machines = Machine.all.where("status <3").order("high DESC").paginate(:page => params[:page], :per_page => 5)
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
    machine.status ="scanned"
    machine.save!
    @results=machine.results
  end

  def downloadresult
    machine=Machine.find(params[:id])
    puts machine.ip
    result_path = Rails.root.join('results','html',"#{ machine.ip }.html")
    send_file result_path
  end

end
