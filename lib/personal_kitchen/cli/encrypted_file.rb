require "base64"
require "thor"

class PersonalKitchen::CLI::EncryptedFile < Thor
  require "personal_kitchen/cli/helpers"

  include PersonalKitchen::CLI::Helpers

  attr_reader :encode
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
  method_option(
    "encode",
    type: :boolean,
    required: false,
    banner: "encode the file as Base64",
    aliases: ["-e"]
  )
  def add(path)
    check_relative!(path)
    @path = path
    @full_path = File.expand_path(path, ENV["HOME"])
    @encode = encode?
    check_file_exists!
    if exists_in_data_bag?
      if !force?
        raise "File '#{full_path}' already exists in the data bag, " +
          "use `--force` to overwrite"
      end
      internal_remove(path)
    end
    files << build_entry
    data_bag.save!
  end

  desc "remove <path>", "remove a file from the encrypted data bag"
  def remove(path)
    check_relative!(path)
    @path = path
    internal_remove(path)
    data_bag.save!
  end

  desc "show <path>", "show content of file in the encrypted data bag"
  method_option(
    "decode",
    type: :boolean,
    required: false,
    banner: "decode Base64 encoded files",
    aliases: ["-e"]
  )
  def show(path)
    @path = path
    @full_path = File.expand_path(path, ENV["HOME"])
    if exists_in_data_bag?
      content = entry["content"]
      encoding = entry["encoding"]
      if encoding == "Base64" && decode?
        puts Base64.decode64(encoding)
      else
        puts content
      end
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
    content = ::File.read(full_path)
    {
      "path" => path,
      "mode" => mode,
    }.tap do |e|
      if encode
        e["encoding"] = "Base64"
        e["content"] = Base64.encode64(content)
      else
        e["content"] = content
      end
    end
  end

  def mode
    m = File::Stat.new(full_path)
    "0" + sprintf("%o", m.mode & 0777)
  end

  def exists_in_data_bag?
    files.any? { |f| f["path"] == path }
  end

  def internal_remove(path)
    files.reject! { |f| f["path"] == path }
  end

  def decode?
    symbolized_options[:decode]
  end

  def encode?
    symbolized_options[:encode]
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
