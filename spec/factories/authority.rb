FactoryBot.define do
  factory :authority do
    sequence(:name) { |n| "authority#{n}" }

    trait :normal do
      id { 1 }
      name { 'normal' }
      add_attribute(:alias) { '一般' }
      description { '権限なし' }
    end

    trait :admin do
      id { 2 }
      name { 'admin' }
      add_attribute(:alias) { '管理者' }
      description { '全てのタスク作成・編集・削除、タスクのアサイン' }
    end

    trait :owner do
      id { 3 }
      name { 'owner' }
      add_attribute(:alias) { '所有者' }
      description { '管理者の権限全て、テーブルの削除' }
    end
  end
end
