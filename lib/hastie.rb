
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

# Most of Hastie functionality is derived from Thor groups.
# Each Thor group is maintained in a separate file.

require 'hastie/report_generator'
require 'hastie/report_publisher'
require 'hastie/report_updater'
require 'hastie/server_generator'
require 'hastie/config_generator'
require 'hastie/report_watcher'
require 'hastie/info'
