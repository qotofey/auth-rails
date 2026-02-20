# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

# Require testcontainers for MySQL BEFORE rails environment
require 'testcontainers'

# Start MySQL container before loading Rails
puts "Starting MySQL container..."
mysql_image = ENV.fetch('MYSQL_IMAGE', 'mysql:8.0-oracle')
$mysql_container = Testcontainers::GenericContainer.new(mysql_image)
  .with_exposed_port(3306)
  .with_env('MYSQL_ROOT_PASSWORD', 'rootpassword')
  .with_env('MYSQL_DATABASE', 'test_db')
  .with_env('MYSQL_USER', 'test')
  .with_env('MYSQL_PASSWORD', 'testpassword')
  .with_command('--default-authentication-plugin=mysql_native_password')

$mysql_container.start

# Wait for MySQL to be ready
sleep 10

# Set environment variables for database.yml
ENV['TEST_DB_HOST'] = $mysql_container.host
ENV['TEST_DB_PORT'] = $mysql_container.mapped_port(3306).to_s
ENV['TEST_DB_DATABASE'] = 'test_db'
ENV['TEST_DB_USERNAME'] = 'test'
ENV['TEST_DB_PASSWORD'] = 'testpassword'

puts "MySQL container started: #{ENV['TEST_DB_HOST']}:#{ENV['TEST_DB_PORT']}"

require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Require database_cleaner
require 'database_cleaner/active_record'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories.
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails uses metadata to mix in different behaviours to your tests
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Database Cleaner configuration for MySQL
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Stop MySQL container after all tests
  config.after(:suite) do
    if defined?($mysql_container) && $mysql_container
      $mysql_container.stop
      $mysql_container.delete
      $mysql_container = nil
    end
  end
end
