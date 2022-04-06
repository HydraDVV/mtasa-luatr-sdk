-- // HydraDVV

addEvent("wastedtime",true)
addEventHandler("wastedtime",root,function()
	time = 200
	timer = setTimer(function ()
	time = time - 1
	--setElementData(localPlayer, "dead_time", time)

	if time >= 0 then
		setTimer ( function()
			if getElementData(localPlayer, "dead") == 0 then
				time = 0
				triggerServerEvent("revive",localPlayer)
			end
		end, 1000, 1 )
	end

	if time == 0 then 
		time = 0 
		triggerServerEvent("revive",localPlayer)
		setTimer(function() 
			end,3000,1) 
			return  
		end
	end, 1000, time)
end)

function noDamageOnDeath ( attacker, weapon, bodypart )
	if ( getElementData(source, "dead") == 1 ) then
		cancelEvent()
	end
end
addEventHandler ( "onClientPlayerDamage", getLocalPlayer(), noDamageOnDeath )

function noKillOnDeath ( attacker, weapon, bodypart )
	if ( getElementData(source, "dead") == 1 ) then
		cancelEvent()
	end
end
addEventHandler ( "onClientPlayerWasted", getLocalPlayer(), noKillOnDeath )

addEventHandler("onClientRender", root,
    function()
    	if getElementData(localPlayer, "dead") == 1 then
    		local scrWidth, scrHeight = guiGetScreenSize()
			dxDrawText("Time: "..time.."", 1, 1, scrWidth, scrHeight - 20, tocolor(0, 0, 0), 1, "default-bold", "center", "bottom")
			dxDrawText("Time: "..time.."", 0, 0, scrWidth, scrHeight - 20, tocolor(255, 255, 255), 1, "default-bold", "center", "bottom")
    	end
    end
)
