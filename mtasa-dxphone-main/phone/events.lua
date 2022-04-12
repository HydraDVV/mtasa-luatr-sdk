exports = exports
ipairs = ipairs
tonumber = tonumber
addEvent = addEvent
addEventHandler = addEventHandler
getRealTime = getRealTime
triggerClientEvent = triggerClientEvent
global = exports.eu_global
boneAttach = exports.eu_bone_attach
connection = exports.eu_mysql
phones = {}
tweets = {}

local smallestDBID = function(dataTable)
    if dataTable then
        local query = dbQuery(connection:getConnection(), "SELECT MIN(e1.id+1) AS nextID FROM "..dataTable.." AS e1 LEFT JOIN "..dataTable.." AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
        local result = dbPoll(query, -1)
        if result then
            local id = tonumber(result[1]["nextID"]) or 1
            return id
        end
        return false
    end
end

local updatePhoneDatas = function(player, phone)
    local phoneContacts = {}
    dbQuery(
        function(qh, source)
            local res, rows, err = dbPoll(qh, 0)
            if rows > 0 then
                for index, value in ipairs(res) do
                    local i = #phoneContacts + 1
					if not phoneContacts[i] then
						phoneContacts[i] = {}
					end
					phoneContacts[i][1] = value.id
                    phoneContacts[i][2] = value.phone
                    phoneContacts[i][3] = value.name
                    phoneContacts[i][4] = value.number
                end
                triggerClientEvent(source, 'phone.contact.data', source, phoneContacts)
            else
                local phoneContacts = {}
                triggerClientEvent(source, 'phone.contact.data', source, phoneContacts)
            end
        end,
    {player}, connection:getConnection(), "SELECT * FROM phone_contacts WHERE phone = ?", phone)

    local phoneHistory = {}
    dbQuery(
        function(qh, source)
            local res, rows, err = dbPoll(qh, 0)
            if rows > 0 then
                for index, value in ipairs(res) do
                    local i = #phoneHistory + 1
                    if not phoneHistory[i] then
                        phoneHistory[i] = {}
                    end
                    phoneHistory[i][1] = value.id
                    phoneHistory[i][2] = value.phone
                    phoneHistory[i][3] = value.number
                    phoneHistory[i][4] = value.hour
                    phoneHistory[i][5] = value.minute
                end
                triggerClientEvent(source, 'phone.history.data', source, phoneHistory)
            else
                local phoneHistory = {}
                triggerClientEvent(source, 'phone.history.data', source, phoneHistory)
            end
        end,
    {player}, connection:getConnection(), "SELECT * FROM phone_historys WHERE phone = ?", phone)
    
    local phoneSms = {}
    dbQuery(
        function(qh, source)
            local res, rows, err = dbPoll(qh, 0)
            if rows > 0 then
                for index, value in ipairs(res) do
                    if value.phone == phone then
                        local i = #phoneSms + 1
                        if not phoneSms[i] then
                            phoneSms[i] = {}
                        end
                        phoneSms[i][1] = value.id
                        phoneSms[i][2] = value.phone
                        phoneSms[i][3] = value.number
                    elseif value.number == phone then
                        local i = #phoneSms + 1
                        if not phoneSms[i] then
                            phoneSms[i] = {}
                        end
                        phoneSms[i][1] = value.id
                        phoneSms[i][2] = value.number
                        phoneSms[i][3] = value.phone
                    end
                end
                triggerClientEvent(source, 'phone.sms.data', source, phoneSms)
            else
                local phoneSms = {}
                triggerClientEvent(source, 'phone.sms.data', source, phoneSms)
            end
        end,
    {player}, connection:getConnection(), "SELECT * FROM phone_sms")
end

local syncTwitter = function()
    triggerClientEvent(root, "phone.sync.twitter", root, tweets)
end

local updateSmsDetails = function(player, phone, num)
    local phoneSmsDetails = {}
    dbQuery(
        function(qh, source)
            local res, rows, err = dbPoll(qh, 0)
            if rows > 0 then
                for index, value in ipairs(res) do
                    if value.number == num then
                        local i = #phoneSmsDetails + 1
                        if not phoneSmsDetails[i] then
                            phoneSmsDetails[i] = {}
                        end
                        phoneSmsDetails[i][1] = value.id
                        phoneSmsDetails[i][2] = value.phone
                        phoneSmsDetails[i][3] = value.number
                        phoneSmsDetails[i][4] = value.message
                        phoneSmsDetails[i][5] = value.hour
                        phoneSmsDetails[i][6] = value.minute
                        phoneSmsDetails[i][7] = value.viewed
                        phoneSmsDetails[i][8] = 0
                    elseif value.number == phone then
                        local i = #phoneSmsDetails + 1
                        if not phoneSmsDetails[i] then
                            phoneSmsDetails[i] = {}
                        end
                        phoneSmsDetails[i][1] = value.id
                        phoneSmsDetails[i][2] = value.number
                        phoneSmsDetails[i][3] = value.phone
                        phoneSmsDetails[i][4] = value.message
                        phoneSmsDetails[i][5] = value.hour
                        phoneSmsDetails[i][6] = value.minute
                        phoneSmsDetails[i][7] = value.viewed
                        phoneSmsDetails[i][8] = 1
                    end
                end
                triggerClientEvent(player, "phone.smsdetails.data", player, phoneSmsDetails)
            else
                local phoneSmsDetails = {}
                triggerClientEvent(player, "phone.smsdetails.data", player, phoneSmsDetails)
            end
        end,
    {source}, connection:getConnection(), "SELECT * FROM phone_sms_details")
end

addEvent('phone.twitter.send', true)
addEventHandler('phone.twitter.send', root, function(message)
    table.insert(tweets, {source.name, message})
    syncTwitter()
end)

addEvent('phone.call.accept', true)
addEventHandler('phone.call.accept', root, function()
    if source then
        local targetPhone = source:getData('callTarget') or nil
        if targetPhone then
            targetPhone:setData('callWaiting', nil)
        end
        source:setData('callWaiting', nil)
    end
end)

addEvent('phone.call.close', true)
addEventHandler('phone.call.close', root, function()
    if source then
        local targetPhone = source:getData('callTarget') or nil
        if targetPhone then
            targetPhone:setData('called', nil)
            targetPhone:setData('caller', nil)
            targetPhone:setData('call.num', nil)
            targetPhone:setData('callTarget', nil)
            targetPhone:setData('call.services', nil)
        end
        source:setData('called', nil)
        source:setData('caller', nil)
        source:setData('call.num', nil)
        source:setData('callTarget', nil)
        source:setData('call.services', nil)
    end
end)

addEvent('phone.call', true)
addEventHandler('phone.call', root, function(num)
    if tonumber(num) then
        local time = getRealTime()
        local hours = time.hour
        if hours < 10 then
            hours = '0'..hours
        end
        local minutes = time.minute
        if minutes < 10 then
            minutes = '0'..minutes
        end
        global:sendLocalMeAction(source, 'Bir kaç numara tuşlar ve telefonunu kulağına götürür.')
        dbExec(connection:getConnection(), "INSERT INTO phone_historys SET id='"..(smallestDBID("phone_historys")).."', phone='"..(source:getData('lastPhoneId')).."', number='"..(num).."', hour='"..hours.."', minute='"..minutes.."'")
        updatePhoneDatas(source, source:getData('lastPhoneId'))
        source:setData('callWaiting', true)
        source:setData('caller', true)
        source:setData('call.num', tonumber(num))
        source:outputChat('[!]#D0D0D0 Aramayı kapatmak için "alt yön tuşuna" basın.',195,184,116,true)
        if tonumber(num) == 155 then
            source:outputChat('#D0D0D0Telefon: İstanbul Emniyet Müdürlüğü lütfen yaşadığınız sorunu bildirin.',195,184,116,true)
            source:setData('callWaiting', nil)
            source:setData('call.services', true)
        elseif tonumber(num) == 112 then
            source:outputChat('#D0D0D0Telefon: İstanbul Devlet Hastanesi lütfen yaşadığınız sorunu bildirin.',195,184,116,true)
            source:setData('callWaiting', nil)
            source:setData('call.services', true)
        elseif tonumber(num) == 156 then
            source:outputChat('#D0D0D0Telefon: İstanbul Emniyet İl Jandarma Komutanlığı lütfen yaşadığınız sorunu bildirin.',195,184,116,true)
            source:setData('callWaiting', nil)
            source:setData('call.services', true)
        else
            source:setData('call.services', nil)
            for _, player in ipairs(Element.getAllByType('player')) do
                if global:hasItem(player, 2, source:getData('call.num')) then
                    if player == source then
                        source:setData('caller', nil)
                        source:setData('call.num', nil)
                        source:setData('callWaiting', nil)
                    else
                        source:setData('callTarget', player)
                        player:setData('callWaiting', true)
                        player:setData('callTarget', source)
                        player:setData('call.num', source:getData('lastPhoneId'))
                        player:setData('called', true)
                        dbExec(connection:getConnection(), "INSERT INTO phone_historys SET id='"..(smallestHistory()).."', phone='"..(source:getData('call.num')).."', number='"..(source:getData('lastPhoneId')).."', hour='"..hours.."', minute='"..minutes.."'")
                        updatePhoneDatas(player, source:getData('call.num'))
                        triggerClientEvent(player, 'phone.ring', player)
                        global:sendLocalDoAction(player, 'Telefonu çalmakta.')
                        player:outputChat('[!]#D0D0D0 Aramayı kabul etmek için "üst yön tuşuna" basın.',195,184,116,true)
                        player:outputChat('[!]#D0D0D0 Aramayı kapatmak için "alt yön tuşuna" basın.',195,184,116,true)
                    end
                end
            end
        end
    else
        source:outputChat('[!]#D0D0D0 Bir şeyler ters gitti!',195,184,116,true)
    end
end)

addEvent('phone.start', true)
addEventHandler('phone.start', root, function()
    local phone = source:getData('lastPhoneId')
    updatePhoneDatas(source, phone)
    if not phones[source] then
        phones[source] = createObject(330, 0, 0, 0)
    end
    boneAttach:attach(phones[source], source, 12, -0.05, 0.02, 0.02, 20, -90, -10)
end)

addEvent('remove.phonedata', true)
addEventHandler('remove.phonedata', root, function()
    local datas = {'lastPhoneId', 'phone.viewed.num', 'phone.target.number', 'call.services', 'called', 'call.num', 'callTarget', 'callWaiting', 'caller'}
    for index, value in ipairs(datas) do
        source:removeData(value)
        boneAttach:detach(phones[source])
        if isElement(phones[source]) then
            phones[source]:destroy()
        end
        phones[source] = nil
    end
end)

addEvent('phone.add.contact', true)
addEventHandler('phone.add.contact', root, function(name, num)
    if name and tonumber(num) then
        dbExec(connection:getConnection(), "INSERT INTO phone_contacts SET id='"..(smallestDBID("phone_contacts")).."', phone='"..(source:getData('lastPhoneId')).."', name='"..(name).."', number='"..(num).."'")
        updatePhoneDatas(source, source:getData('lastPhoneId'))
    else
        source:outputChat('[!]#D0D0D0 Bir şeyler ters gitti!',195,184,116,true)
    end
end)

addEvent('phone.delete.contact', true)
addEventHandler('phone.delete.contact', root, function(phone, db)
    if tonumber(db) then
        dbExec(connection:getConnection(), "DELETE FROM phone_contacts WHERE id='" ..(db).. "' LIMIT 1")
        updatePhoneDatas(source, phone)
    else
        source:outputChat('[!]#D0D0D0 Bir şeyler ters gitti!',195,184,116,true)
    end
end)

addEvent('phone.delete.history', true)
addEventHandler('phone.delete.history', root, function(phone, db)
    if tonumber(db) then
        dbExec(connection:getConnection(), "DELETE FROM phone_historys WHERE id='" ..(db).. "' LIMIT 1")
        updatePhoneDatas(source, phone)
    else
        source:outputChat('[!]#D0D0D0 Bir şeyler ters gitti!',195,184,116,true)
    end
end)

addEvent('phone.sms.viewed', true)
addEventHandler('phone.sms.viewed', root, function(phone, db)
    if tonumber(db) then
        dbExec(connection:getConnection(), "UPDATE `phone_sms_details` SET `viewed`='2' WHERE id='" ..(db).. "' LIMIT 1")
        updatePhoneDatas(source, phone)
    else
        source:outputChat('[!]#D0D0D0 Bir şeyler ters gitti!',195,184,116,true)
    end
end)

addEvent('phone.sms.details', true)
addEventHandler('phone.sms.details', root, function(phone, num)
    if tonumber(phone) and tonumber(num) then
        updateSmsDetails(source, phone, num)
    end
end)

addEvent('phone.new.message', true)
addEventHandler('phone.new.message', root, function(num, message)
    if tonumber(num) and message then
        local time = getRealTime()
        local hours = time.hour
        if hours < 10 then
            hours = '0'..hours
        end
        local minutes = time.minute
        if minutes < 10 then
            minutes = '0'..minutes
        end
        source:setData('phone.target.number', tonumber(num))
        dbExec(connection:getConnection(), "INSERT INTO phone_sms SET id='"..(smallestDBID("phone_sms")).."', phone='"..(source:getData('lastPhoneId')).."', number='"..(source:getData('phone.target.number')).."'")
        dbExec(connection:getConnection(), "INSERT INTO phone_sms_details SET id='"..(smallestDBID("phone_sms_details")).."', phone='"..(source:getData('lastPhoneId')).."', number='"..(source:getData('phone.target.number')).."', message='"..(message).."', hour='"..(hours).."', minute='"..(minutes).."'")
        updatePhoneDatas(source, source:getData('lastPhoneId'))
        for _, player in ipairs(Element.getAllByType('player')) do
            if global:hasItem(player, 2, source:getData('phone.target.number')) then
                if player == source then else
                    global:sendLocalDoAction(player, 'Telefonuna bir mesaj bildirimi geldi.')
                    if player:getData('phone:opened') then
                        if player:getData('lastPhoneId') == source:getData('phone.target.number') then
                            updatePhoneDatas(player, player:getData('lastPhoneId'))
                            updateSmsDetails(source, source:getData('phone.target.number'), num)
                        end
                    end
                end
            end
        end
    else
        source:outputChat('[!]#D0D0D0 Bir şeyler ters gitti!',195,184,116,true)
    end
end)

addEvent('phone.message', true)
addEventHandler('phone.message', root, function(num, message)
    if tonumber(num) and message then
        local time = getRealTime()
        local hours = time.hour
        if hours < 10 then
            hours = '0'..hours
        end
        local minutes = time.minute
        if minutes < 10 then
            minutes = '0'..minutes
        end
        source:setData('phone.target.number', tonumber(num))
        dbExec(connection:getConnection(), "INSERT INTO phone_sms_details SET id='"..(smallestDBID("phone_sms_details")).."', phone='"..(source:getData('lastPhoneId')).."', number='"..(source:getData('phone.target.number')).."', message='"..(message).."', hour='"..(hours).."', minute='"..(minutes).."'")
        updatePhoneDatas(source, source:getData('lastPhoneId'))
        updateSmsDetails(source, source:getData('lastPhoneId'), num)
        for _, player in ipairs(Element.getAllByType('player')) do
            if global:hasItem(player, 2, source:getData('phone.target.number')) then
                if player == source then else
                    global:sendLocalDoAction(player, 'Telefonuna bir mesaj bildirimi geldi.')
                    if player:getData('phone:opened') then
                        if player:getData('lastPhoneId') == source:getData('phone.target.number') then
                            updatePhoneDatas(player, player:getData('lastPhoneId'))
                            updateSmsDetails(player, source:getData('phone.target.number'), num)
                        end
                    end
                end
            end
        end
    else
        source:outputChat('[!]#D0D0D0 Bir şeyler ters gitti!',195,184,116,true)
    end
end)

addEvent('phone.password', true)
addEventHandler('phone.password', root, function(password)
    if tonumber(password) then
        dbQuery(
			function(qh, source)
				local res, rows, err = dbPoll(qh, 0)
				if rows > 0 then
					for index, row in ipairs(res) do
                        if row['password'] == password then
                            triggerClientEvent(source, 'phone.success.password', source)
                        else
                            source:outputChat('[!]#D0D0D0 Hatalı bir şifre girdiniz.',195,184,116,true)
                        end
					end
				else
                    dbExec(connection:getConnection(), "INSERT INTO phone_settings SET phone='"..(source:getData('lastPhoneId')).."', password='"..(password).."'")
                    source:outputChat('[!]#D0D0D0 Telefonunuzun yeni şifresi '..password..' olarak belirlendi.',195,184,116,true)
                    triggerClientEvent(source, 'phone.success.password', source)
                end
			end,
		{source}, connection:getConnection(), "SELECT * FROM phone_settings WHERE phone = ?", source:getData('lastPhoneId'))
    else
        source:outputChat('[!]#D0D0D0 Bir şeyler ters gitti!',195,184,116,true)
    end
end)
