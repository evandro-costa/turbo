--- Turbo.lua Github Feed
--
-- Copyright 2013 John Abrahamsen
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- This implementation uses the Github REST API to pull current amount of
-- watchers for the Turbo.lua repository.

export TURBO_SSL = true

with require "turbo"
 yield = coroutine.yield
 
 class GithubFeed extends .web.RequestHandler
  
  get: (search) =>
   res = yield .async.HTTPClient!\fetch "https://api.github.com/repos/kernelsauce/turbo"
   
   if res.error or res.headers\get_status_code! != 200
    error .web.HTTPError\new 500, res.error.message
    
   json = .escape.json_decode res.body
   
   @write [[<html><head></head><body>]]
   
   @write string.format [[
    <h1>Turbo.lua Github feed<h1>
    <p>Current watchers %d</p>
    ]],
    json.watchers_count

   @write [[</body></html>]]
   
 with .web.Application\new {
  {"^/$", GithubFeed}
 }
  \listen 8888
  
 .ioloop.instance!\start!
