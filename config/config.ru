require "rubygems"
require "cijoe"

use Rack::CommonLogger

$project_path = File.dirname(__FILE__) + "/repo"

CIJoe::Server.configure do |config|
  config.set :project_path, $project_path
  config.set :show_exceptions, true
  config.set :lock, true
end

run CIJoe::Server
