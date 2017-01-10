# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/collect"

describe LogStash::Filters::Collect do
  #config.expect_with(:rspec) { |c| c.syntax = :should }

  def get_event(contents = {})
    contents['@timestamp'] = LogStash::Timestamp.new
    contents['host'] = 'somehost'
    contents['message'] = 'some message for event'
    LogStash::Event.new(contents)
  end

  it 'Test get_event method' do
    e = get_event({'field1': 'val1'})
    e.set('test', 1234)
    e.to_hash
  end

  it 'Test new filter no config' do
    expect { LogStash::Filters::Collect.new({}) }.to raise_error(LogStash::ConfigurationError)
  end

  it 'Property can be a list' do
    config = {'field' => 'object_array', 'property' => %w(property to get)}
    LogStash::Filters::Collect.new(config)
  end

  it 'Property can be a single string' do
    config = {'field' => 'object_array', 'property' => 'prop'}
    LogStash::Filters::Collect.new(config)
  end

  it 'Override collection default' do
    config = {'field' => 'object_array', 'property' => 'prop', 'collection' => 'some_collection'}
    LogStash::Filters::Collect.new(config)
  end

  it 'Passing in invalid collection adds error tag' do
    config = {'field' => 'people', 'property' => 'name', 'collection' => 'names'}
    f = LogStash::Filters::Collect.new(config)
    e = get_event({'people' => 'scalar value'})
    f.filter(e)
    e.get('tags').should include('_collect_error')
  end

  it 'Test list of simple objects (only 1 level to de-reference)' do
    ppl = [{'id' => 12, 'name' => 'Mike'}, {'id' => 13, 'name' => 'Sam'}]
    config = {'field' => 'people', 'property' => 'name', 'collection' => 'names'}
    f = LogStash::Filters::Collect.new(config)
    e = get_event({'people' => ppl})
    f.filter(e)

    expect(e.get('names').class).to be(Array)
    expect(e.get('names').include?('Mike')).to be(true)
    expect(e.get('names').include?('Sam')).to be(true)
  end

  it 'Test list of not-so-simple objects (> 1 level to de-reference)' do
    ppl = [{ 'person' => {'id' => 12, 'name' => 'Mike'} }, {'person' => {'id' => 13, 'name' => 'Sam'}}]
    config = {'field' => 'people', 'property' => %w(person name), 'collection' => 'names'}
    f = LogStash::Filters::Collect.new(config)
    e = get_event({'people' => ppl})
    f.filter(e)
    expect(e.get('names').class).to be(Array)
    expect(e.get('names').include?('Mike')).to be(true)
    expect(e.get('names').include?('Sam')).to be(true)
  end

end
