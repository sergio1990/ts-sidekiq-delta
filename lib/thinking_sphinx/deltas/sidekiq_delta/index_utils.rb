module ThinkingSphinx::Deltas::SidekiqDelta::IndexUtils
  extend self

  # Public: Return a list of index prefixes (i.e. without "_core"/"_delta").
  #
  # Examples
  #
  #   sphinx_indices
  #   # => ['foo', 'bar']
  #
  # Returns an Array of index prefixes.
  def index_prefixes
    @prefixes ||= indices.map { |i| i.gsub /_(core|delta)$/, "" }.uniq
  end

  def core_indices
    @core_indices ||= indices.select { |i| i =~ /_core$/ }
  end

  def delta_indices
    @delta_indices ||= indices.select { |i| i =~ /_delta$/ }
  end

  def reload!
    @ts_config = @indices = @prefixes = @core_indices = @delta_indices = nil
  end

  def delta_to_core(delta_name)
    delta_name.sub(/_delta$/, '_core')
  end

  def core_to_delta(core_name)
    core_name.sub(/_core$/, '_delta')
  end

  def ts_config
    @ts_config ||= ThinkingSphinx::Configuration.instance.tap do |config|
      config.preload_indices
    end
  end

  private
  def indices
    @indices ||= ts_config.indices.collect { |i| i.name }
  end

end
