require 'rails_helper'

RSpec.describe Blog, type: :model do
  let(:user) { create(:user) }
  let(:blog) { create(:blog, user: user) }



  describe "validation" do
    it "valid with attributes" do
      expect(blog).to be_valid
    end
  end

end
