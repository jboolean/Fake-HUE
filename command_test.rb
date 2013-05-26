require 'json'
require 'pp'

light1_to = open("pipes/1-to", "w+")
light1_from =  open("pipes/1-from", "r+")
light1_to.puts ({"command" => "name"}.to_json)
light1_to.flush

pp JSON.parse(light1_from.gets)

light1_to.puts ({"command" => "all"}.to_json)
light1_to.flush

pp JSON.parse(light1_from.gets)

new_state = {"on" => true, "bri" => 255, "alert" => "lselect"}
light1_to.puts ({"command" => "put state", "state" => new_state}.to_json)
light1_to.flush

pp JSON.parse(light1_from.gets)

light1_to.puts ({"command" => "exit"}.to_json)
light1_to.flush

