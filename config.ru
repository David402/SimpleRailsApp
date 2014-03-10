# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# ---- Load the API environment
require ::File.expand_path('../api/config/environment', __FILE__)

# --------------------------------------------------------------
# Top-level routing
map('/api')     { run SimpleApi::SinatraApp }
map('/')        { run SimpleRailsApp::Application }
