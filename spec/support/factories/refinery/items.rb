
FactoryGirl.define do
  factory :item, :class => Refinery::Blog::Item do
    sequence(:title) { |n| "refinery#{n}" }
  end
end

