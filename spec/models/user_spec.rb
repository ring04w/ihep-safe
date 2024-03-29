require 'spec_helper'

describe User do

  before do
    @user = User.new(name:"default",email:"user@example.com")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:role) }

  it { should be_valid }
  it { should be_member }
  it { should_not be_admin }
  it { should_not be_superadmin }

  its(:remember_token) { should_not be_present }
  its(:email) { should be_present }

  describe "set role admin " do
    before do

      @user.save!
      @user.admin!

    end

    it { should be_admin }
  end

  describe "set role superadmin " do
    before do
      @user.save!
      @user.superadmin!

    end

    it { should_not  be_admin }
    it { should_not  be_member }
    it { should be_superadmin }
  end

  describe "when name not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when email id not present" do
    before { @user.email= " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name="a"*51 }
    it { should_not be_valid }
  end

  describe "when name is too short" do
    before { @user.name="a" }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. 
        foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

end
