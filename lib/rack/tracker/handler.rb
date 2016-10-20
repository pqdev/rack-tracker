class Rack::Tracker::Handler
  class_attribute :position_options
  class_attribute :position_options_ns
  
  self.position_options    = { head: :append }
  self.position_options_ns = { body: :prepend }

  attr_accessor :options
  attr_accessor :env

  # Allow javascript escaping in view templates
  include Rack::Tracker::JavaScriptHelper

  def initialize(env, options = {})
    self.env = env
    self.options = options
    self.position_options    = options[:position] if options[:position]
    self.position_options_ns = options[:position_ns] if options[:position_ns]
  end

  def events
    events = env.fetch('tracker', {})[self.class.to_s.demodulize.underscore] || []
    events.map{ |ev| "#{self.class}::#{ev['class_name']}".constantize.new(ev.except('class_name')) }
  end

  def render
    raise NotImplementedError.new('needs implementation')
  end
  
  def render_ns
    return ""
  end

  def self.track(name, event)
    raise NotImplementedError.new("class method `#{__callee__}` is not implemented.")
  end

  def self.position(options=nil)
    self.position_options = options if options
    self.position_options
  end
  
  def self.position_ns(options=nil)
    self.position_options_ns = options if options
    self.position_options_ns
  end

  def position
    self.position_options
  end
  
  def position_ns
    self.position_options_ns
  end
end
