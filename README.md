# Logstash Collect Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

Author: Mike Baranski (mike.baranski@gmail.com).  Contributions are welcome.

[![Gem Version](https://badge.fury.io/rb/logstash-filter-collect.svg?reload=1)](https://badge.fury.io/rb/logstash-filter-collect)
[![Build Status](https://travis-ci.org/mikebski/logstash-filter-collect.svg?branch=master)](https://travis-ci.org/mikebski/logstash-filter-collect)
[![Code Climate](https://codeclimate.com/github/mikebski/logstash-filter-collect/badges/gpa.svg?reload=1)](https://codeclimate.com/github/mikebski/logstash-filter-collect)
[![Coverate](https://codeclimate.com/github/mikebski/logstash-filter-collect/badges/coverage.svg?reload=1)](https://codeclimate.com/github/mikebski/logstash-filter-collect)
## License ##

Copyright (c) 2014–2017 Mike Baranski <http://www.mikeski.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Installation

To install from rubygems.org:

    bin/logstash-plugin install logstash-filter-collect

If you'd like to build locally, you should clone the repo and run:

    bundle install
    gem build logstash-filter-collect.gemspec
    bin/logstash-plugin install --local ./logstash-filter-collect-1.0.0.gem
    
Make sure that the argument is the correct filename 
(the gem that `gem build` creates) since the version might be different

## Usage

This plugin takes a list of objects in your event and turns it into a 
list of strings.  The original purpose of this was to take something like this:

     lop => [{ 'person' => {'id' => 12, 'name' => 'Mike'} }, {'person' => {'id' => 13, 'name' => 'Sam'}}]

and turn it into a list like this:

    names => ['Mike', 'Sam']
    
With this filter plugin, the following configuration will do that:
    
    collect => {
        'field' => 'people', 
        'property' => ['person' 'name'], 
        'collection' => 'names'
    }
    
Here is a quick one-line example of using this plugin:

    echo '[{ "person": { "id": 1, "name": "Mike" } }, { "person": { "id": 2, "name": "Sam" } }]' |  ~/apps/logstash-5.1.1/bin/logstash -e 'filter { collect { field => "message" property => ["person", "name"] collection => "names"} } output { stdout { codec=> rubydebug}}'
