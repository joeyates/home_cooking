class PersonalKitchen::CLI::Defaults < Thor
  include Thor::Actions

  DATA_BAG = "personal"
  DATA_BAG_ITEM = "defaults"

  attr_reader :username

  def initialize(username:)
    super([])
    @username = username
  end

  no_commands do
    def run
      data_bag.set(:username, username) if username
      data_bag.save!
    end
  end

  private

  def data_bag
    @data_bag ||=
      PersonalKitchen::DataBag.new(group: "personal", item: "defaults")
  end
end
