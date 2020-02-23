require "base64"
require "diffy"
require "thor"

class HomeCooking::CLI::EncryptedFile < Thor
  require "home_cooking/cli/helpers"

  include HomeCooking::CLI::Helpers

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
        puts Base64.decode64(content)
      else
        puts content
      end
    else
      raise "The file '#{full_path}' is not present in the data bag"
    end
  end

  desc "install <path>", "install a file from the encrypted data bag"
  def install(path)
    @path = path
    @full_path = File.expand_path(path, ENV["HOME"])
    if !exists_in_data_bag?
      raise "The file '#{full_path}' is not present in the data bag"
    end
    content = entry["content"]
    encoding = entry["encoding"]
    if encoding == "Base64" && decode?
      content = Base64.decode64(content)
    end

    File.write(full_path, content)
    File.chmod(entry["mode"].to_i(8), full_path)
  end

  desc "info <path>", "dump information about file in the encrypted data bag"
  def info(path)
    @path = path
    @full_path = File.expand_path(path, ENV["HOME"])
    if !exists_in_data_bag?
      raise "The file '#{full_path}' is not present in the data bag"
    end

    puts "entry: #{entry.inspect}"
  end

  desc "diff <path>", "show difference between on-disk and data bag versions of a file"
  def diff(path)
    @path = path
    @full_path = File.expand_path(path, ENV["HOME"])

    if !exists_in_data_bag?
      raise "The file '#{full_path}' is not present in the data bag"
    end

    if !File.exist?(full_path)
      raise "The file '#{full_path}' is not present on disk"
    end

    data_bag = entry["content"]
    encoding = entry["encoding"]
    if encoding == "Base64"
      data_bag = Base64.decode64(data_bag)
    end

    on_disk = ::File.read(full_path)

    return if data_bag == on_disk

    puts Diffy::Diff.new(data_bag, on_disk).to_s(:color)
  end

  desc "changed", "list files which have been changed on disk"
  def changed
    changed = files.filter do |f|
      path = f["path"]
      data_bag = f["content"]
      encoding = f["encoding"]
      if encoding == "Base64"
        data_bag = Base64.decode64(data_bag)
      end

      full_path = File.expand_path(path, ENV["HOME"])

      if File.exist?(full_path)
        on_disk = ::File.read(full_path)
        data_bag != on_disk
      else
        true
      end
    end
    names = changed.map { |f| f["path"] }

    return if names.empty?

    puts names.sort.join("\n")
  end

  desc "list", "list files in the encrypted data bag"
  def list
    puts files.map { |f| f["path"] }.sort.join("\n")
  end

  private

  def data_bag
    @data_bag ||=
      HomeCooking::DataBag.new(group: "personal", item: "files")
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
