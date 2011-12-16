require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fakefs_helper')
require 'hastie/report_publisher'

describe Hastie::ReportPublisher do

  def read_file file
    if File.exists? file
      File.open(file, 'r').read
    else
      ""
    end
  end

end
