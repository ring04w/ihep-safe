require 'spec_helper'

describe Machine do
  let(:user) { FactoryGirl.create(:user) }
  before do
    @machine=Machine.new(ip:"127.0.0.1",user_id: user.id)
  end
  subject{ @machine }

  it { should respond_to(:ip) }
  it { should respond_to(:user) }
  it { should respond_to(:high) }
  it { should respond_to(:mid) }
  it { should respond_to(:low) }
  it { should respond_to(:status) }
  it { should respond_to(:created_at) }
  it { should respond_to(:updated_at) }

  describe "when user_id id not present" do
    before { @machine.user_id=nil }
    it { should_not be_valid }
  end

  describe "when ip format is invalid" do
    it "should be invalid" do
      ips=%w[a.1.2.b a.b.c.d 1112.1.2.5]
      ips.each do |invalid_ip|
        @machine.ip=invalid_ip
        expect(@machine).not_to be_valid
      end
    end
  end

end
