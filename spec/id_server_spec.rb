require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fakefs_helper')
require 'hastie/id_server'


describe Hastie::IdServer do

  before :each do
    @config_file = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "hastie_config"))
    @server_url = "http://0.0.0.0:3000"
    @server_issuer = "cbio"
    @id_server = Hastie::IdServer.new(@server_url, @server_issuer)
    @lab = "TEST"
    @sponsor = "cbio_tst"
  end

  it "should create new id" do
    response = @id_server.request_id(@lab, @sponsor)

    response["project"].should_not == nil
    response["project"]["id"].should_not == nil

    id = response["project"]["id"]

    id.should match /cbio\.cbio_tst\.\d+/


  end

  it "should include analyst" do
    options = {:analyst => "___"}
    response = @id_server.request_id(@lab, @sponsor, options)
    response["project"]["lead"].should == "___"
  end


end

