
FactoryGirl.define do
  factory :author, :class => Refinery::Blog::Author do
    sequence(:last_name) { |n| "refinery#{n}" }
  end
end

