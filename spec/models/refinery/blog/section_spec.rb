require 'spec_helper'

module Refinery
  module Blog
    describe Section do
      describe "validations", type: :model do
        subject do
          FactoryGirl.create(:section,
          :slug => "Refinery CMS")
        end

        it { should be_valid }
        its(:errors) { should be_empty }
        its(:slug) { should == "Refinery CMS" }
      end
    end
  end
end
