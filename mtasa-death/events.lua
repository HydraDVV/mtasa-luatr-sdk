-- // HydraDVV

addEventHandler ("onPlayerWasted", root, 
   	function()
   		local x,y,z = getElementPosition(source)
		local int = getElementInterior(source)
		local dim = getElementDimension(source)
		local team = getPlayerTeam(source)
		local rotx, roty, rotz = getElementRotation(source)
		local skin = getElementModel(source)
   		
   		fadeCamera ( source, false, 2.5, 0, 0, 0)
   		setElementData(source, "dead", 1)
   		spawnPlayer(source, x, y, z, rotz, skin, int, dim, team)
   		triggerClientEvent(source,"wastedtime",source)
   		setPedAnimation( source, "crack", "crckdeth3", false)
   		setElementHealth(source, 15)
   	end
)

function rev()
	local x,y,z = getElementPosition(source)
	local int = getElementInterior(source)
	local dim = getElementDimension(source)
	local team = getPlayerTeam(source)
	local rotx, roty, rotz = getElementRotation(source)
	local skin = getElementModel(source)
	
	fadeCamera(source, true, 1.5)
	setElementData(source, "dead", 0)
   	setPedAnimation(source)
end
addEvent("revive",true)
addEventHandler("revive",root,rev)