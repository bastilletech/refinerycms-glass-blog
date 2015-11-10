
FactoryGirl.define do
  factory :tag, :class => Refinery::Blog::Tag do
    sequence(:title) { |n| "refinery#{n}" }
  end
end

