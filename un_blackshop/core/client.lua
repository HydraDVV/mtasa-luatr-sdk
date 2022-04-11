Click = Service:new('blackMarket')
activated = false
font = DxFont('components/Roboto.ttf', 9)

Click.constructor = function(button, state, _,_,_,_,_, clickedElement)
	if button == 'right' and state == 'down' then
		if isElement(clickedElement) then
			if clickedElement ~= localPlayer then
				local type =  clickedElement.type
				if type == 'ped' and clickedElement:getData('black:market') then
					if activated then
						Click.close()
					else
						activated = true
						counter = 0
						size = 25
						Click.pullOptions(clickedElement)
						for index, value in ipairs(pulledOptions) do
							counter = counter + 1.28
						end
						Click.render = Timer(
							function()
								if getDistanceBetweenPoints3D(localPlayer.position.x, localPlayer.position.y, localPlayer.position.z, clickedElement.position.x, clickedElement.position.y, clickedElement.position.z) < 3 then
									local elementPos = clickedElement:getPosition()
									local x, y = getScreenFromWorldPosition(elementPos)
									dxDrawRectangle(x, y, 150, size*counter, tocolor(0,0,0,255))
									dxDrawOuterBorder(x, y, 150, size*counter, 2, tocolor(10,10,10,250))
									for key, value in pairs(pulledOptions) do
										if isMouseInPosition(x, y, 150, size+7) then
											dxDrawRectangle(x, y, 150, size+7, tocolor(5,5,5,250))
											dxDrawText(value[1], x+15, y+7, 150, size+7, tocolor(200,200,200,250), 1, font)
										else
											dxDrawRectangle(x, y, 150, size+7, tocolor(5,5,5,225))
											dxDrawText(value[1], x+15, y+7, 150, size+7, tocolor(200,200,200,250), 1, font)
										end
										if isMouseInPosition(x, y, 150, size+7) and getKeyState("mouse1") then
											Click.close()
											value[2]()
										end
										y = y + 32
									end
								else
									Click.close()
								end
							end,
						0, 0)
					end
				end
			end
		end
	end
end

Click.close = function()
	pulledOptions = {}
	activated = false
	killTimer(Click.render)
end

Click.pullOptions = function(element)
	local type =  element.type
	if type == 'ped' and element:getData('black:market') then
		pulledOptions = {
			{'Muşta (₺'..knuckleCash..')', function()
				triggerServerEvent('black.market.give', localPlayer, knuckleCash, 1)
			end,},
			{'Colt-45 (₺'..coltCash..')', function()
				triggerServerEvent('black.market.give', localPlayer, coltCash, 22)
			end,},
			{'Deagle (₺'..deagleCash..')', function()
				triggerServerEvent('black.market.give', localPlayer, deagleCash, 24)
			end,},
			{'Uzi (₺'..uziCash..')', function()
				triggerServerEvent('black.market.give', localPlayer, uziCash, 28)
			end,},
			{'Tec-9 (₺'..tec9Cash..')', function()
				triggerServerEvent('black.market.give', localPlayer, tec9Cash, 32)
			end,},
			{'MP-5 (₺'..mp5Cash..')', function()
				triggerServerEvent('black.market.give', localPlayer, mp5Cash, 29)
			end,},
			{'Shotgun (₺'..shotgunCash..')', function()
				triggerServerEvent('black.market.give', localPlayer, shotgunCash, 25)
			end,},
		}
	end
end

addEventHandler('onClientClick', root, Click.constructor)
