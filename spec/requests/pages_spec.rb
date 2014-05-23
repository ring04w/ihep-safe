require 'spec_helper'

describe "Pages" do
  subject { page }

  describe "Home page" do
    before { visit root_path }

    it { should have_content('Safe IHEP') }
    it { should have_title('Safe IHEP') }
  end
end
