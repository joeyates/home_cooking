module PersonalKitchen::CLI::Helpers
  def symbolized(options)
    options.reduce({}) { |h, (k, v)| h[k.intern] = v; h }
  end
end
