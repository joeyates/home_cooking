require "home_cooking"
require "open3"

RSpec.describe "home_cooking script" do
  it "calls HomeCooking::CLI" do
    command = "./bin/home_cooking help"
    stdout, stderr, status = Open3.capture3(command)
    expect(stdout).to match(/Commands:/)
  end
end
