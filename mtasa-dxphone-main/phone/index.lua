triggerServerEvent = triggerServerEvent
dxDrawCircle = dxDrawCircle
dxDrawImage = dxDrawImage
dxDrawRectangle = dxDrawRectangle
dxDrawText = dxDrawText
tocolor = tocolor
localPlayer = getLocalPlayer()
ipairs = ipairs
addEvent = addEvent
addEventHandler = addEventHandler
exports = exports
bindKey = bindKey
getKeyState = getKeyState
getTickCount = getTickCount
fonts = exports.eu_fonts
phone = {}
phone.__index = phone

function phone:create()
    local instance = {}
    setmetatable(instance, phone)
    if instance:constructor() then
        return instance
    end
    return false
end

function phone:constructor()
    self = phone;
    self.screen = Vector2(guiGetScreenSize())
    self.zone = Vector2(self.screen.x *0.03, self.screen.y * 0.01)
    self.sizeX, self.sizeY = (self.screen.x-150-self.zone.x-120), (self.screen.y)
    self.roboto = fonts:getFont('Roboto', 11)
    self.robotoSize = fonts:getFont('Roboto', 21)
    self.robotoB = fonts:getFont('RobotoB', 11)
    self.tweets = {}
    self.apps = {
        {2, 'Ayarlar', 'settings'},
        {3, 'Rehber', 'contacts'},
        {4, 'Mesajlar', 'messages'},
        {5, 'Aramalar', 'history'},
		{6, 'Twitter', 'twitter'},
    }
    localPlayer:setData('call.services', nil)
    localPlayer:setData('phone:opened', nil)
    localPlayer:setData('called', nil)
    localPlayer:setData('callWaiting', nil)
    localPlayer:setData('caller', nil)
    localPlayer:setData('call.num', nil)
    localPlayer:setData('callTarget', nil)
    addEventHandler('onClientCharacter', root, function(...) self:write(...) end)
    addEventHandler("onClientKey", root, function(...) self:cancelKey(...) end)
	bindKey('backspace', 'down', self.delete)
    bindKey("mouse_wheel_down", "down", self.wheelDown)
    bindKey("mouse_wheel_up", "down", self.wheelUp)
    local events = {'phone.success.password', 'phone.sync.twitter', 'phone.contact.data', 'phone.history.data', 'phone.sms.data', 'phone.smsdetails.data', 'phone.ring', 'phone.open'}
    for _, event in ipairs(events) do
        addEvent(event, true)
    end
    addEventHandler('phone.success.password', root, self.openPassword)
    addEventHandler('phone.sync.twitter', root, function(...) self:tweetSync(...) end)
    addEventHandler('phone.contact.data', root, function(...) self:contactData(...) end)
    addEventHandler('phone.history.data', root, function(...) self:historyData(...) end)
    addEventHandler('phone.sms.data', root, function(...) self:smsData(...) end)
    addEventHandler('phone.smsdetails.data', root, function(...) self:smsDetailsData(...) end)
    addEventHandler('phone.ring', root, self.ring)
    addEventHandler('phone.open', root, self.open)
end

function phone:open()
    self = phone;
    if self.active then
        self.active = false
        if isTimer(self.render) then
            killTimer(self.render)
        end
        localPlayer:setData('phone:opened', false)
        triggerServerEvent('remove.phonedata', localPlayer)
    else
        self.active = true
        self.passwordText = ''
        self.text = ''
        self.numberText = ''
		self.messageText = ''
        self.page = 0
        self.sidePage = 1
        self.click = 0
        self.scroll = 0
		self.lineText = 27
        self.selectedTable = nil
        localPlayer:setData('phone:opened', true)
        triggerServerEvent('phone.start', localPlayer)
        self.render = Timer(self.display, 0, 0)
    end
end

function phone:display()
    self = phone;
    self:roundedRectangle(self.sizeX+20, self.sizeY-50-490+8, 230, 460, 10, tocolor(25,25,25,255))

    if localPlayer:getData('caller') then
        if localPlayer:getData('callWaiting') then
            self.callText = ''..self:getContactName(localPlayer:getData('call.num'))..' Aranıyor..'
            self.textWidth = string.len(self.callText)*4
            dxDrawText(self.callText, self.sizeX+170-self.textWidth, self.sizeY-50-325, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
        else
            self.callText = ''..self:getContactName(localPlayer:getData('call.num'))..' Aramada'
            self.textWidth = string.len(self.callText)*4
            dxDrawText(self.callText, self.sizeX+155-self.textWidth, self.sizeY-50-325, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
        end
    elseif localPlayer:getData('called') then
        if localPlayer:getData('callWaiting') then
            self.callText = ''..self:getContactName(localPlayer:getData('call.num'))..' Arıyor..'
            self.textWidth = string.len(self.callText)*4
            dxDrawText(self.callText, self.sizeX+170-self.textWidth, self.sizeY-50-325, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
            if getKeyState('arrow_u') and self.click+600 <= getTickCount() then
                self.click = getTickCount()
                triggerServerEvent('phone.call.accept', localPlayer)
            end
        else
            self.callText = ''..self:getContactName(localPlayer:getData('call.num'))..' Aramada'
            self.textWidth = string.len(self.callText)*4
            dxDrawText(self.callText, self.sizeX+155-self.textWidth, self.sizeY-50-325, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
        end
    elseif self.page == 0 then
        self.selectedText = 'password'
        dxDrawText('6 Haneli Şifrenizi Girin', self.sizeX+75, self.sizeY-50-250, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
        dxDrawText(string.gsub(self.passwordText, '.', '*'), self.sizeX+115, self.sizeY-50-225, 25, 25, tocolor(200,200,200,255), 1, self.roboto)
        if getKeyState('enter') and self.click+600 <= getTickCount() then
            if string.len(self.passwordText) == 6 then
                self.click = getTickCount()
                triggerServerEvent('phone.password', localPlayer, self.passwordText)
            end
        end
    elseif self.page == 1 then
        self.lineApp = 4
        self.counter = 0
        self.counterX = 0
        self.counterY = 0
        for _, value in ipairs(self.apps) do
            if self:isInBox(self.sizeX+40+self.counterX, self.sizeY-50-440+self.counterY, 40, 60) then
                dxDrawImage(self.sizeX+40+self.counterX, self.sizeY-50-440+self.counterY, 40, 40, 'components/images/'..value[3]..'.png', 0, 0, 0, tocolor(225,225,225,250))
                dxDrawText(value[2], self.sizeX+43.5+self.counterX, self.sizeY-50-395+self.counterY, 25, 25, tocolor(225,225,225,255), 0.68, self.roboto)
                if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                    self.click = getTickCount()
                    self.page = value[1]
                    self.selectedText = nil
                    self.text = ''
					self.lineText = 27
                    self.scroll = 0
                    self.sidePage = 1
                    self.numberText = ''
					self.messageText = ''
                end
            else
                dxDrawImage(self.sizeX+40+self.counterX, self.sizeY-50-440+self.counterY, 40, 40, 'components/images/'..value[3]..'.png', 0, 0, 0, tocolor(200,200,200,250))
                dxDrawText(value[2], self.sizeX+43.5+self.counterX, self.sizeY-50-395+self.counterY, 25, 25, tocolor(200,200,200,255), 0.68, self.roboto)
            end
            self.counter = self.counter + 1
            self.counterX = self.counterX + 50
            if self.counter == self.lineApp then
                self.counterX = 0
                self.counterY = self.counterY + 65
                self.lineApp = self.lineApp + 4
            end
        end
    elseif self.page == 2 then
        dxDrawImage(self.sizeX+110, self.sizeY-50-340, 55, 55, 'components/images/bored.png', 0, 0, 0, tocolor(200,200,200,250))
    elseif self.page == 3 then
        if self:isInBox(self.sizeX+35, self.sizeY-50-435, 200, 25) then
            self:roundedRectangle(self.sizeX+35, self.sizeY-50-435, 200, 25, 5, tocolor(115,115,115,250))
            if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                self.click = getTickCount()
                self.text = ''
                self.selectedText = 'name'
            end
        else
            self:roundedRectangle(self.sizeX+35, self.sizeY-50-435, 200, 25, 5, tocolor(100,100,100,250))
        end
        dxDrawImage(self.sizeX+45, self.sizeY-50-430, 17, 17, 'components/images/self.png', 0, 0, 0, tocolor(15,15,15,250))
        dxDrawText(self.text, self.sizeX+65, self.sizeY-50-430, 25, 25, tocolor(15,15,15,255), 0.75, self.robotoB)

        if self:isInBox(self.sizeX+35, self.sizeY-50-405, 200, 25) then
            self:roundedRectangle(self.sizeX+35, self.sizeY-50-405, 200, 25, 5, tocolor(115,115,115,250))
            if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                self.click = getTickCount()
                self.numberText = ''
                self.selectedText = 'number'
            end
        else
            self:roundedRectangle(self.sizeX+35, self.sizeY-50-405, 200, 25, 5, tocolor(100,100,100,250))
        end
        dxDrawImage(self.sizeX+45, self.sizeY-50-400, 17, 17, 'components/images/call.png', 0, 0, 0, tocolor(15,15,15,250))
        dxDrawText(self.numberText, self.sizeX+65, self.sizeY-50-400, 25, 25, tocolor(15,15,15,255), 0.75, self.robotoB)

        if getKeyState('enter') and self.click+600 <= getTickCount() then
            self.click = getTickCount()
            triggerServerEvent('phone.add.contact', localPlayer, self.text, self.numberText)
        end
        
        dxDrawText('Kişi', self.sizeX+55, self.sizeY-50-360, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
        dxDrawText('Telefon', self.sizeX+167.5, self.sizeY-50-360, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
        self.selectedTable = self.contact
        self.maxScroll = 12
        self.counter = 0
        self.counterY = 0
        for index, value in ipairs(self.contact) do
            if index > self.scroll and self.counter < self.maxScroll then
                if self:isInBox(self.sizeX+35, self.sizeY-50-337+self.counterY, 200, 20) then
                    self:roundedRectangle(self.sizeX+35, self.sizeY-50-337+self.counterY, 200, 20, 8, tocolor(8,8,8,250))
                    if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                        self.click = getTickCount()
                        triggerServerEvent('phone.call', localPlayer, value[4])
                    end
                    if getKeyState('mouse2') and self.click+600 <= getTickCount() then
                        self.click = getTickCount()
                        triggerServerEvent('phone.delete.contact', localPlayer, value[2], value[1])
                    end
                else
                    self:roundedRectangle(self.sizeX+35, self.sizeY-50-337+self.counterY, 200, 20, 8, tocolor(15,15,15,250))
                end
                dxDrawText(value[3], self.sizeX+40, self.sizeY-50-335+self.counterY, 25, 25, tocolor(200,200,200,255), 0.75, self.roboto)
                dxDrawText(value[4], self.sizeX+162.5, self.sizeY-50-335+self.counterY, 25, 25, tocolor(200,200,200,255), 0.75, self.roboto)
                self.counter = self.counter + 1
                self.counterY = self.counterY + 23
            end
        end
    elseif self.page == 4 then
        if self.sidePage == 1 then
            dxDrawText('Son Mesajlar', self.sizeX+40, self.sizeY-50-430, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
            if self:isInBox(self.sizeX+215, self.sizeY-50-445, 10, 25) then
                dxDrawText('+', self.sizeX+218, self.sizeY-50-445, 25, 25, tocolor(52,108,182,255), 0.85, self.robotoSize)
                if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                    self.click = getTickCount()
                    self.sidePage = 2
                end
            else
                dxDrawText('+', self.sizeX+218, self.sizeY-50-445, 25, 25, tocolor(22,91,182,255), 0.85, self.robotoSize)
            end
            self.selectedTable = self.sms
            self.maxScroll = 5
            self.counter = 0
            self.counterY = 0
            for index, value in ipairs(self.sms) do
                if index > self.scroll and self.counter < self.maxScroll then
                    if self:isInBox(self.sizeX+35, self.sizeY-50-385+self.counterY, 200, 50) then
                        self:roundedRectangle(self.sizeX+35, self.sizeY-50-385+self.counterY, 200, 55, 8, tocolor(17,17,17,250))
                        if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                            self.click = getTickCount()
                            triggerServerEvent('phone.sms.details', localPlayer, value[2], value[3])
                            self.sidePage = 3
                        end
                    else
                        self:roundedRectangle(self.sizeX+35, self.sizeY-50-385+self.counterY, 200, 55, 8, tocolor(20,20,20,250))
                    end
                    dxDrawText(self:getContactName(value[3]), self.sizeX+45, self.sizeY-50-380+self.counterY, 25, 25, tocolor(175,175,175,255), 0.75, self.roboto)
                    dxDrawText('Mesaj içeriğini görmek için tıklayın..', self.sizeX+45, self.sizeY-50-363+self.counterY, 25, 25, tocolor(175,175,175,255), 0.70, self.roboto)
                    self.counter = self.counter + 1
                    self.counterY = self.counterY + 62
                end
            end
        elseif self.sidePage == 2 then
            if self:isInBox(self.sizeX+35, self.sizeY-50-435, 200, 25) then
                self:roundedRectangle(self.sizeX+35, self.sizeY-50-435, 200, 25, 5, tocolor(115,115,115,250))
                if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                    self.click = getTickCount()
                    self.numberText = ''
                    self.selectedText = 'number'
                end
            else
                self:roundedRectangle(self.sizeX+35, self.sizeY-50-435, 200, 25, 5, tocolor(100,100,100,250))
            end
            dxDrawText('Mesajınızın içeriği', self.sizeX+35, self.sizeY-50-150, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
            dxDrawImage(self.sizeX+45, self.sizeY-50-430, 17, 17, 'components/images/call.png', 0, 0, 0, tocolor(15,15,15,250))
            dxDrawText(self:getContactName(self.numberText), self.sizeX+65, self.sizeY-50-430, 25, 25, tocolor(15,15,15,255), 0.75, self.robotoB)

            if self:isInBox(self.sizeX+35, self.sizeY-50-130, 200, 60) then
                self:roundedRectangle(self.sizeX+35, self.sizeY-50-130, 200, 60, 8, tocolor(15,15,15,250))
                if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                    self.click = getTickCount()
                    self.messageText = ''
                    self.selectedText = 'message'
                end
            else
                self:roundedRectangle(self.sizeX+35, self.sizeY-50-130, 200, 60, 8, tocolor(20,20,20,250))
            end
            dxDrawText(self.messageText, self.sizeX+40, self.sizeY-50-125, 25, 25, tocolor(200,200,200,255), 0.75, self.roboto)
            if string.len(self.messageText) > 0 and string.len(self.numberText) > 0 then
                if getKeyState('enter') and self.click+600 <= getTickCount() then
                    self.click = getTickCount()
                    triggerServerEvent('phone.new.message', localPlayer, self.numberText, self.messageText)
                    self.sidePage = 1
                    self.messageText = ''
                    self.numberText = ''
                end
            end
        elseif self.sidePage == 3 then
            self.selectedText = 'message'
            self.selectedTable = self.smsDetails
            self.counter = 0
            self.counterY = 0
            self.maxScroll = 4
            for index, value in ipairs(self.smsDetails) do
                if index > self.scroll and self.counter < self.maxScroll then
                    self:roundedRectangle(self.sizeX+35, self.sizeY-50-435+self.counterY, 200, 65, 8, tocolor(20,20,20,250))
                    if value[8] == 0 then
                        dxDrawText('Siz:', self.sizeX+40, self.sizeY-50-430+self.counterY, 25, 25, tocolor(175,175,175,250), 0.75, self.roboto)
                    else
                        dxDrawText('Karşı:', self.sizeX+40, self.sizeY-50-430+self.counterY, 25, 25, tocolor(175,175,175,250), 0.75, self.roboto)
                        triggerServerEvent('phone.sms.viewed', localPlayer, value[2], value[1])
                    end
                    dxDrawText(''..value[5]..':'..value[6], self.sizeX+203, self.sizeY-50-430+self.counterY, 25, 25, tocolor(175,175,175,250), 0.75, self.roboto)
                    dxDrawText(value[4], self.sizeX+40, self.sizeY-50-415+self.counterY, 25, 25, tocolor(175,175,175,250), 0.75, self.roboto)
                    dxDrawImage(self.sizeX+210, self.sizeY-50-390+self.counterY, 20, 20, 'components/images/tick'..value[7]..'.png')
                    self.counter = self.counter + 1
                    self.counterY = self.counterY + 70
                    if string.len(self.messageText) > 0 then
                        if getKeyState('enter') and self.click+600 <= getTickCount() then
                            self.click = getTickCount()
                            triggerServerEvent('phone.message', localPlayer, value[3], self.messageText)
                            self.messageText = ''
                            self.lineText = 27
                        end
                    end
                end
            end
            if self:isInBox(self.sizeX+35, self.sizeY-50-130, 200, 60) then
                self:roundedRectangle(self.sizeX+35, self.sizeY-50-130, 200, 60, 8, tocolor(17,17,17,250))
                if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                    self.click = getTickCount()
                    self.messageText = ''
                    self.lineText = 27
                end
            else
                self:roundedRectangle(self.sizeX+35, self.sizeY-50-130, 200, 60, 8, tocolor(20,20,20,250))
            end
            dxDrawText('Mesajınızın içeriği', self.sizeX+35, self.sizeY-50-150, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
            dxDrawText(self.messageText, self.sizeX+40, self.sizeY-50-125, 25, 25, tocolor(200,200,200,255), 0.75, self.roboto)
        end
    elseif self.page == 5 then
        self.selectedText = 'number'
        if string.len(self.numberText) > 3 then
            if self:isInBox(self.sizeX+215, self.sizeY-50-445, 10, 25) then
                dxDrawText('+', self.sizeX+218, self.sizeY-50-445, 25, 25, tocolor(52,108,182,255), 0.85, self.robotoSize)
                if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                    self.click = getTickCount()
                    self.page = 3
                end
            else
                dxDrawText('+', self.sizeX+218, self.sizeY-50-445, 25, 25, tocolor(22,91,182,255), 0.85, self.robotoSize)
            end
        end
        self.textWidth = string.len(self.numberText)*4
        if tonumber(self:getContactName(self.numberText)) then
            dxDrawText(self:getContactName(self.numberText), self.sizeX+135-self.textWidth, self.sizeY-50-395, 25, 25, tocolor(200,200,200,255), 1.10, self.roboto)
        else
            dxDrawText(self:getContactName(self.numberText), self.sizeX+77.5, self.sizeY-50-395, 25, 25, tocolor(200,200,200,255), 1.10, self.roboto)
        end
        if getKeyState('enter') and self.click+600 <= getTickCount() then
            self.click = getTickCount()
            triggerServerEvent('phone.call', localPlayer, self.numberText)
        end
        dxDrawText('Son Aranan', self.sizeX+40, self.sizeY-50-335, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
        dxDrawText('Saat', self.sizeX+180, self.sizeY-50-335, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
        self.selectedTable = self.history
        self.maxScroll = 11
        self.counter = 0
        self.counterY = 0
        for index, value in ipairs(self.history) do
            if index > self.scroll and self.counter < self.maxScroll then
                if self:isInBox(self.sizeX+35, self.sizeY-50-315+self.counterY, 200, 20) then
                    self:roundedRectangle(self.sizeX+35, self.sizeY-50-315+self.counterY, 200, 20, 8, tocolor(8,8,8,250))
                    if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                        self.click = getTickCount()
                        triggerServerEvent('phone.call', localPlayer, value[3])
                    end
                    if getKeyState('mouse2') and self.click+600 <= getTickCount() then
                        self.click = getTickCount()
                        triggerServerEvent('phone.delete.history', localPlayer, value[2], value[1])
                    end
                else
                    self:roundedRectangle(self.sizeX+35, self.sizeY-50-315+self.counterY, 200, 20, 8, tocolor(15,15,15,250))
                end
                dxDrawText(self:getContactName(value[3]), self.sizeX+40, self.sizeY-50-312+self.counterY, 25, 25, tocolor(200,200,200,255), 0.75, self.roboto)
                dxDrawText(''..value[4]..':'..value[5], self.sizeX+180, self.sizeY-50-312+self.counterY, 25, 25, tocolor(200,200,200,255), 0.75, self.roboto)
                self.counter = self.counter + 1
                self.counterY = self.counterY + 23
            end
        end
    elseif self.page == 6 then
        self.selectedText = 'message'
		self.selectedTable = self.tweets
		self.counter = 0
		self.counterY = 0
		self.maxScroll = 4
		for index, value in ipairs(self.tweets) do
			if index > self.scroll and self.counter < self.maxScroll then
				self:roundedRectangle(self.sizeX+35, self.sizeY-50-435+self.counterY, 200, 65, 8, tocolor(95,135,165,250))
				dxDrawImage(self.sizeX+210, self.sizeY-50-430+self.counterY, 15, 15, 'components/images/tweet.png', 0, 0, 0, tocolor(35,35,35,250))
				dxDrawText(''..value[1]..' tweetledi', self.sizeX+40, self.sizeY-50-430+self.counterY, 25, 25, tocolor(25,25,25,250), 0.75, self.roboto)
				dxDrawText(value[2], self.sizeX+40, self.sizeY-50-415+self.counterY, 25, 25, tocolor(25,25,25,250), 0.75, self.roboto)
				self.counter = self.counter + 1
				self.counterY = self.counterY + 70
			end
		end
		dxDrawText('Hadi bir şeyler tweetle', self.sizeX+35, self.sizeY-50-150, 25, 25, tocolor(200,200,200,255), 0.75, self.robotoB)
        if self:isInBox(self.sizeX+35, self.sizeY-50-130, 200, 60) then
		    self:roundedRectangle(self.sizeX+35, self.sizeY-50-130, 200, 60, 8, tocolor(17,17,17,250))
            if getKeyState('mouse1') and self.click+600 <= getTickCount() then
                self.click = getTickCount()
                self.messageText = ''
				self.lineText = 27
            end
        else
            self:roundedRectangle(self.sizeX+35, self.sizeY-50-130, 200, 60, 8, tocolor(20,20,20,250))
        end
		if string.len(self.messageText) > 0 then
			if getKeyState('enter') and self.click+600 <= getTickCount() then
				self.click = getTickCount()
                triggerServerEvent('phone.twitter.send', localPlayer, self.messageText)
				self.messageText = ''
				self.lineText = 27
			end
		end
		dxDrawText(self.messageText, self.sizeX+40, self.sizeY-50-125, 25, 25, tocolor(200,200,200,255), 0.75, self.roboto)
    end

    dxDrawImage(self.sizeX+10, self.sizeY-50-535, 250, 500, 'components/images/bar.png')
    dxDrawImage(self.sizeX, self.sizeY-50-500, 270, 500, 'components/images/mask.png')

    if getKeyState('arrow_d') and self.click+600 <= getTickCount() then
        self.click = getTickCount()
        if localPlayer:getData('called') or localPlayer:getData('caller') then
            self.page = 0
            triggerServerEvent('phone.call.close', localPlayer)
        else
            if self.sidePage > 1 then
                self.scroll = 0
                self.sidePage = 1
            else
                if self.page <= 1 then
                    self:open()
                else
                    self.scroll = 0
                    self.page = 1
                end
            end
        end
    end

    if self:isInBox(self.sizeX+60, self.sizeY-50-40, 150, 5) then
        dxDrawRectangle(self.sizeX+60, self.sizeY-50-40, 150, 5, tocolor(175,175,175,250))
        if getKeyState('mouse1') and self.click+600 <= getTickCount() then
            self.click = getTickCount()
            if localPlayer:getData('called') or localPlayer:getData('caller') then
                triggerServerEvent('phone.call.close', localPlayer)
                self.page = 0
            else
                if self.sidePage > 1 then
                    self.scroll = 0
                    self.sidePage = 1
                else
                    if self.page <= 1 then
                        self:open()
                    else
                        self.scroll = 0
                        self.page = 1
                    end
                end
            end
        end
    else
        dxDrawRectangle(self.sizeX+60, self.sizeY-50-40, 150, 5, tocolor(225,225,225,250))
    end
end

function phone:ring()
    self = phone;
    self.active = true
    self.passwordText = ''
    self.text = ''
    self.numberText = ''
	self.messageText = ''
    self.page = 0
    self.sidePage = 1
    self.click = 0
    self.scroll = 0
	self.lineText = 27
    self.selectedTable = nil
    localPlayer:setData('phone:opened', true)
    if isTimer(self.render) then
        killTimer(self.render)
    end
    self.render = Timer(self.display, 0, 0)
end

function phone:getContactName(num)
    self = phone;
    if tonumber(num) then
        localPlayer:setData('phone.viewed.num', tonumber(num))
        for _, row in ipairs(self.contact) do
            if row[4] == localPlayer:getData('phone.viewed.num') then
                return row[3]
            end
        end
    end
    return num
end

function phone:tweetSync(dat)
    self = phone;
    self.tweets = dat
end

function phone:smsDetailsData(dat)
    self = phone;
    self.smsDetails = dat or {}
end

function phone:smsData(dat)
    self = phone;
    self.sms = dat or {}
end

function phone:historyData(dat)
    self = phone;
    self.history = dat or {}
end

function phone:contactData(dat)
    self = phone;
    self.contact = dat or {}
end

function phone:cancelKey(button, press)
    self = phone;
    if self.active then
        if self.page == 1 then else
            if localPlayer:getData('called') or localPlayer:getData('caller') then else
                if button == 't' then
                    cancelEvent()
                end
            end 
        end
    end
end

function phone:openPassword()
    self = phone;
    self.page = 1
end

function phone:write(character)
	self = phone;
    if self.selectedText == 'password' then
        if tonumber(character) then
            if string.len(self.passwordText) < 6 then
                self.passwordText = ''..self.passwordText..''..character
                self.char = string.len(self.passwordText)+1
            end
        end
    elseif self.selectedText == 'number' then
        if tonumber(character) then
            if string.len(self.numberText) < 11 then
                self.numberText = ''..self.numberText..''..character
                self.char = string.len(self.numberText)+1
            end
        end
    elseif self.selectedText == 'name' then
        if string.len(self.text) < 18 then
            self.text = ''..self.text..''..character
            self.char = string.len(self.text)+1
        end
    elseif self.selectedText == 'message' then
		if string.len(self.messageText) < 80 then
			if string.len(self.messageText) > self.lineText then
				self.lineText = self.lineText + 27
			end
			if string.len(self.messageText) > 0 then
                if string.len(self.messageText) == self.lineText then
				    self.messageText = ''..self.messageText..'\n'
                end
			end
			self.messageText = ''..self.messageText..''..character
			self.char = string.len(self.messageText)+1
		end
	end
end

function phone:delete()
	self = phone;
    if self.selectedText == 'password' then
        if string.len(self.passwordText) > 0 then
            local fistPart = self.passwordText:sub(0, self.char-1)
            local lastPart = self.passwordText:sub(self.char+1, #self.passwordText)
            self.passwordText = fistPart..lastPart
            self.char = string.len(self.passwordText)
        end
    elseif self.selectedText == 'number' then
        if string.len(self.numberText) > 0 then
            local fistPart = self.numberText:sub(0, self.char-1)
            local lastPart = self.numberText:sub(self.char+1, #self.numberText)
            self.numberText = fistPart..lastPart
            self.char = string.len(self.numberText)
        end
    elseif self.selectedText == 'name' then
        if string.len(self.text) > 0 then
            local fistPart = self.text:sub(0, self.char-1)
            local lastPart = self.text:sub(self.char+1, #self.text)
            self.text = fistPart..lastPart
            self.char = string.len(self.text)
        end
    elseif self.selectedText == 'message' then
		if string.len(self.messageText) > 0 then
			if string.len(self.messageText) < self.lineText then
				self.lineText = self.lineText - 27
			end
            local fistPart = self.messageText:sub(0, self.char-1)
            local lastPart = self.messageText:sub(self.char+1, #self.messageText)
            self.messageText = fistPart..lastPart
            self.char = string.len(self.messageText)
        end
	end
end

function phone:wheelUp()
    self = phone;
    if self.active then
        if self.scroll > 0 then
            self.scroll = self.scroll - 1
        end
    end
end

function phone:wheelDown()
    self = phone;
    if self.active then
        if self.scroll < #self.selectedTable - self.maxScroll then
            self.scroll = self.scroll + 1
        end
    end
end

function phone:roundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

function phone:isInBox(xS,yS,wS,hS)
    if(isCursorShowing()) then
        local cursorX, cursorY = getCursorPosition()
        sX,sY = guiGetScreenSize()
        cursorX, cursorY = cursorX*sX, cursorY*sY
        if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
            return true
        else
            return false
        end
    end
end

phone:create()