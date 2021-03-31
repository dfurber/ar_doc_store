require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

namespace :test do
  task :prepare_ar_doc_store do
    config = { adapter: 'postgresql', database: 'ar_doc_store_test', username: 'postgres', password: 'postgres' }
    require 'active_record'
    ActiveRecord::Tasks::DatabaseTasks.create(config)
    ActiveRecord::Base.establish_connection(config)

    ActiveRecord::Schema.define do
      self.verbose = false
      create_table :buildings, force: true do |t|
        t.jsonb :data
      end
      create_table :purchase_orders, force: true do |t|
        t.jsonb :data
      end
    end
  end
end