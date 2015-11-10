require 'spec_helper'

module Refinery
  module Blog
    describe Item do
      describe "validations", type: :model do
        subject do
          FactoryGirl.create(:item,
          :title => "Refinery CMS")
        end

        it { should be_valid }
        its(:errors) { should be_empty }
        its(:title) { should == "Refinery CMS" }
      end
    end
  end
end
