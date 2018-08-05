require "thor"

class PersonalKitchen::CLI::EncryptedFile < Thor
  require "personal_kitchen/cli/helpers"

  include PersonalKitchen::CLI::Helpers

  attr_reader :full_path
  attr_reader :path

  desc "add <path> [--force]", "add a file to the encrypted data bag"
  method_option(
    "force",
    type: :boolean,
    required: false,
    banner: "force overwrite of existing files",
    aliases: ["-f"]
  )
  def add(path)
    check_relative!(path)
    @path = path
    @full_path = File.expand_path(path, ENV["HOME"])
    check_file_exists!
    if exists_in_data_bag?
      if !force?
        raise "File '#{full_path}' already exists in the data bag, " +
          "use `--force` to overwrite"
      end
      remove(path)
    end
    files << build_entry
    data_bag.save!
  end

  desc "show <path>", "show content of file in the encrypted data bag"
  def show(path)
    @path = path
    @full_path = File.expand_path(path, ENV["HOME"])
    if exists_in_data_bag?
      puts entry["content"]
    else
      raise "The file '#{full_path}' is not present in the data bag"
    end
  end

  desc "list", "list files in the encrypted data bag"
  def list
    puts files.map { |f| f["path"] }.sort.join("\n")
  end

  private

  def data_bag
    @data_bag ||=
      PersonalKitchen::DataBag.new(group: "personal", item: "files")
  end

  def build_entry
    {
      "path" => path,
      "mode" => mode,
      "content" => ::File.read(full_path)
    }
  end

  def mode
    m = File::Stat.new(full_path)
    "0" + sprintf("%o", m.mode & 0777)
  end

  def exists_in_data_bag?
    files.any? { |f| f["path"] == path }
  end

  def remove(path)
    files.reject! { |f| f["path"] == path }
  end

  def entry
    files.find { |f| f["path"] == path }
  end

  def files
    data_bag.get("files")
  end

  def force?
    symbolized_options[:force]
  end

  def symbolized_options
    symbolized(options)
  end

  def check_relative!(path)
    if
      path.start_with?("/") ||
        path.start_with?("./") ||
        path.start_with?("../")
      raise "Please supply a path relative to your home directory"
    end
  end

  def check_file_exists!
    raise "File '#{full_path}' does not exist" if !::File.exist?(full_path)
  end
end
