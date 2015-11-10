
FactoryGirl.define do
  factory :category, :class => Refinery::Blog::Category do
    sequence(:title) { |n| "refinery#{n}" }
  end
end

