
FactoryGirl.define do
  factory :section, :class => Refinery::Blog::Section do
    sequence(:slug) { |n| "refinery#{n}" }
  end
end

