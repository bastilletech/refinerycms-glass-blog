require 'spec_helper'

module Refinery
  module Blog
    describe Author do
      describe "validations", type: :model do
        subject do
          FactoryGirl.create(:author,
          :last_name => "Refinery CMS")
        end

        it { should be_valid }
        its(:errors) { should be_empty }
        its(:last_name) { should == "Refinery CMS" }
      end
    end
  end
end
