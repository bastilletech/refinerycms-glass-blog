require 'spec_helper'

module Refinery
  module Blog
    describe Category do
      describe "validations", type: :model do
        subject do
          FactoryGirl.create(:category,
          :title => "Refinery CMS")
        end

        it { should be_valid }
        its(:errors) { should be_empty }
        its(:title) { should == "Refinery CMS" }
      end
    end
  end
end
