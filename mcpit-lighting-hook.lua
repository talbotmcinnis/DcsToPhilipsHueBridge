local mcpitLightingCallbacks = {}

package.path  = package.path..";.\\LuaSocket\\?.lua"

function set_hue()
	local http = require('socket')
	
	local host, port = "192.168.84.48", 80
	local tcp = assert(socket.tcp())

	tcp:connect(host, port);
	tcp:send([[PUT /api/NlP62doq8KP1ea70WjWujURKR9LMF6eQTRkvhF5p/lights/7/state HTTP/1.1
Host: 192.168.84.48
Content-Length: 53
Content-Type: text/plain;charset=UTF-8
Origin: http://192.168.84.48

{"on":true, "sat": 254, "bri":254, "xy":[0.16,0.68]} ]]);

	while true do
		local s, status, partial = tcp:receive()
		--log.write("[MCPIT-LIGHTING]", log.INFO, (s or partial))
		if status == "closed" then
		  break
		end
	end

	tcp:close()
end

function mcpitLightingCallbacks.onSimulationStart()
	log.write("[MCPIT-LIGHTING]", log.INFO, "onSimulationStart")
	log.write("[MCPIT-LIGHTING]", log.INFO, "onSimulationStart:Complete")
end

local last_set_time = -30
function mcpitLightingCallbacks.onSimulationFrame()
	-- log.write("[MCPIT-LIGHTING]", log.INFO, "onSimulationFrame")
	local model_time = DCS.getModelTime()
	if(model_time > 3 and model_time - last_set_time > 30) then
		local get_mission_start_date = [[
			return tostring(env.mission.date.Year) .. "-" .. tostring(env.mission.date.Month) .. "-" .. tostring(env.mission.date.Day) .. "T" .. tostring(env.mission.start_time)
		]]

		local result = net.dostring_in("server", get_mission_start_date)
		log.write("[MCPIT-LIGHTING]", log.INFO, "Got Time:" .. result .. "+" .. model_time)
		set_hue()		
		last_set_time = model_time
	--else
	--	log.write("[MCPIT-LIGHTING]", log.INFO, string.format("Tock: %f/%f", last_set_time, model_time))
	end
end

DCS.setUserCallbacks(mcpitLightingCallbacks)  -- here we set our callbacks