class MachinesController < ApplicationController
  before_action :signed_in_user,only: [:index]

  def index
    @machines = current_user.machines
  end
end
