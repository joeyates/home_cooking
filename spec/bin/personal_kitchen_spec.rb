require "personal_kitchen"
require "open3"

RSpec.describe "personal_kitchen script" do
  it "calls PersonalKitchen::CLI" do
    command = "./bin/personal_kitchen help"
    stdout, stderr, status = Open3.capture3(command)
    expect(stdout).to match(/Commands:/)
  end
end
