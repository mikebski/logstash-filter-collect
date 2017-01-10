# encoding: utf-8
require 'json'
require 'logstash/filters/base'
require 'logstash/namespace'

# This  filter will replace the contents of the default 
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an .
class LogStash::Filters::Collect < LogStash::Filters::Base

  # This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #    collect {
  #     field => 'object_array_field',
  #     property => ['property', 'of', 'each', 'object'],
  #     collection => 'output_list_name',
  #   }
  # }
  #
  config_name 'collect'

  # Replace the message with this value.
  config :field, :validate => :string, :required => true
  config :property, :validate => :array, :required => true
  config :collection, :validate => :string, :required => true, :default => 'collection'
  config :error_tags, :validate => :array, :required => true, :default => ['_collect_error']

  public
  def register
    # Add instance variables 
  end

  private
  def plugin_error(message, event)
    @logger.error("Collect filter error: #{message}")
    LogStash::Util::Decorators.add_tags(@error_tags, event, "filters/#{self.class.name}")
  end

  private
  def get_nested_property_from_object(property_array, source)
    interim_object = source
    @property.each { |x|
      interim_object = interim_object[x]
    }
    return interim_object
  end

  public
  def filter(event)
    object_array = event.get(@field)
    if not object_array.class == Array
      begin
        object_array = JSON.parse(object_array)
      rescue
        nil
      end

      if not object_array.class == Array
        plugin_error("Error, #{@field} is not an array or parseable JSON", event)
        return
      end
    end

    new_collection = []
    object_array.each { |obj|
      # Add the value to the new collection
      new_collection.push(get_nested_property_from_object(@property, obj))
    }

    event.set(@collection, new_collection)
    filter_matched(event)
  end # def filter

end # class LogStash::Filters::Collect
