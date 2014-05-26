class MachinesController < ApplicationController
  before_action :signed_in_user,only: [:index]

  def index
    @machines = current_user.machines
  end
  def show
    @machine = Machine.find(params[:id])
  end

  def startscan
    machine=Machine.find(params[:id])
    machine.status = "scanning"
    #machine.status = "waiting"
    machine.save!
    puts "Enter start"
    puts machine.ip
    ScanWorker.perform_async(machine.ip)
    redirect_to user_machines_path(current_user)
  end
end
