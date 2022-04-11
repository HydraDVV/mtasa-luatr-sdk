mysql = exports.un_mysql
connection = mysql:getConnection()

general = {}

general.getDate = function()

    local date   = getRealTime()
    local day    = date.monthday < 10 and "0"..date.monthday or date.monthday
    local month  = date.month + 1 < 10 and "0"..date.month + 1 or date.month + 1
    local year   = date.year + 1900
    local hour   = date.hour < 10 and "0"..date.hour or date.hour
    local minute = date.minute < 10 and "0"..date.minute or date.minute

    return day.."."..month.."."..year.." / "..hour..":"..minute

end

general.findValue = function(inputValue, record, reason)

    local playerName  = string.lower(tostring(inputValue):gsub("_" , " "))
    local returnValue = nil
    local sourcePlayer = source

    dbQuery(function(qh)

        local res, rows = dbPoll(qh , 0)

        if rows > 0 then

            local foundCount = 2
            local playerRow  = nil 

            for key , row in pairs(res) do 

                local rowName = string.lower(tostring(row.charactername):gsub("_" , " "))

                if playerName == rowName then
                    return general:insertPersonel(row, record, reason , sourcePlayer)
                else

                    local findS, findE = string.find(rowName , playerName)

                    if findS and tonumber(findE-findS) > foundCount then
                        foundCount = findE-findS
                        returnValue = row
                    end

                end

            end

            if returnValue then 
                return general:insertPersonel(returnValue, record, reason , sourcePlayer)
            end

        end

    end , connection , "SELECT * FROM characters")

    dbQuery(function(qh)

        local res, rows = dbPoll(qh , 0)

        if rows > 0 then
            return general:insertPersonel(res[1], record, reason , sourcePlayer)
        end

    end , connection , "SELECT * FROM vehicles WHERE plate='"..(string.upper(inputValue)).."'")

end
addEvent("mdc.insert" , true)
addEventHandler("mdc.insert" , root , general.findValue)

general.getVehicle = function(self , value)

    for k , vehicle in pairs(getElementsByType("vehicle")) do 

        if tostring(vehicle:getData("plate")) == tostring(value) then
            return vehicle
        end

    end

end

general.getInterior = function(self , value)

    for k , interior in pairs(getElementsByType("interior")) do 

        if tostring(interior:getData("dbid")) == tostring(value) then
            return interior
        end

    end

end

general.insertPersonel = function(self , element, record, reason, sourcePlayer)

    if not element then
        return outputChatBox("[!]#ffffff Plaka veya kişi bulunamadı!" , sourcePlayer , 255 , 0 , 0 , true)
    end

    local database = record == "record" and "mdc_records" or "mdc_wanteds"
    local dbid = element.id
    local type = element.charactername and "player" or "vehicle";
    if type == "vehicle" then
        vehShopData = exports["un_vehicle_manager"]:getInfoFromVehShopID(tonumber(dbid))
    end
    local name  = type == "player" and element.charactername or vehShopData.vehbrand.." "..vehShopData.vehmodel; --
    local plate = type == "vehicle" and element.plate or ""
    local date  = general:getDate()
    local author = tostring(sourcePlayer:getData("account:username")) or "" 

    local exec = dbExec(connection , "INSERT INTO "..database.." SET id='"..(dbid).."', type='"..(type).."', name='"..(name).."', plate='"..(plate).."', reason='"..(tostring(reason)).."', date='"..(date).."', author='"..(author).."'")

    if exec then
        dbQuery(wanteds.loadWanteds , connection , "SELECT * FROM mdc_wanteds");
        return outputChatBox("[!]#ffffff Eklenme başarıyla sonuçlandı!" , sourcePlayer , 0 , 255 , 0 , true)
    end

end

addEvent("mdc.question" , true)
addEventHandler("mdc.question" , root , function(type, input)

	local player = source

    if type ~= "personel" then

        dbQuery(function(qh)

            local res, rows = dbPoll(qh , 0)
    
            if rows > 0 then
                checkQuestion(player , type, input, res[1].owner)
                return
            end
    
        end , connection , "SELECT * FROM "..type.."s WHERE id='"..(tostring(input)).."' or plate='"..(string.upper(input)).."'")

    else
        checkQuestion(player , type, input , nil)
    end

end)

function checkQuestion(player , type, input , returnValue)

    if returnValue then

        dbQuery(function(qh)

            local res, rows = dbPoll(qh , 0)

            if rows > 0 then
                questionPage(player , type, input , res[1])
                return
            end

        end , connection , "SELECT * FROM characters WHERE id='"..(tonumber(returnValue)).."'")

    else

        local playerName  = string.lower(tostring(input):gsub("_" , " "))
        dbQuery(function(qh)

            local res, rows = dbPoll(qh , 0)
    
            if rows > 0 then
    
                local foundCount = 3
                local playerRow  = nil 
    
                for key , row in pairs(res) do 
    
                    local rowName = string.lower(tostring(row.charactername):gsub("_" , " "))

                    if playerName == rowName then
                        questionPage(player , type , input , row)
                        return
                    else
    
                        local findS, findE = string.find(rowName , playerName)

                        if findS then 
                            findS = findS-1
                            
                            if tonumber(findE-findS) > foundCount then
                                foundCount = findE-findS
                                questionPage(player , type , input , row)
                                return
                            end
                        end
    
                    end
    
                end
    
            end
    
        end , connection , "SELECT * FROM characters")

    end

end

function questionPage(player , type, input , returnValue)

    if not returnValue then
        return outputChatBox("[!]#ffffff Girdiğiniz değerlerde bir mülkiyet, araç veya kişi bulunamadı!" , player , 255 , 0 , 0 , true)
    else

        local race = returnValue.skincolor
        if race == 0 then
            race = "Beyaz"
        else
            race = race == 1 and "Siyahi" or "Asyalı"
        end

        local phoneNumber = nil

        dbQuery(function(qh)

            local res, rows = dbPoll(qh , 0)

            if rows > 0 then
                for k , v in pairs(res) do 
                    if tonumber(v.itemID) == 2 then
                        phoneNumber = tonumber(v.itemValue)
                    end
                end
            end

        end , connection , "SELECT * FROM items WHERE owner='"..returnValue.id.."'")

        setTimer(function()

            if not phoneNumber then
                phoneNumber = "Kayıtsız telefon"
            end

            triggerClientEvent(player , "mdc.execute" , player , "vm.page = 'result'")
            triggerClientEvent(player , "mdc.execute" , player , "vm.tablist[0].name   = '"..returnValue.charactername:gsub("_" , " ").."'")
            triggerClientEvent(player , "mdc.execute" , player , "vm.tablist[0].phone  = '"..phoneNumber.."'")
            triggerClientEvent(player , "mdc.execute" , player , "vm.tablist[0].race   = '"..race.."'")
            triggerClientEvent(player , "mdc.execute" , player , "vm.tablist[0].weight = "..returnValue.weight.."")
            triggerClientEvent(player , "mdc.execute" , player , "vm.tablist[0].height = "..returnValue.height.."")
            triggerClientEvent(player , "mdc.execute" , player , "vm.tablist[0].age    = "..returnValue.age.."")
            triggerClientEvent(player , "mdc.execute" , player , "vm.tablist[0].money  = '"..returnValue.bankmoney.."$'")

            dbQuery(function(qh)

                local res, rows = dbPoll(qh , 0)
    
                if rows > 0 then

                    for k , v in pairs(res) do 
                        
                        if tonumber(v.deleted) == 0 then

                            local vehShopData = exports["un_vehicle_manager"]:getInfoFromVehShopID(tonumber(v.model))
                            local vehicle = general:getVehicle(tostring(v.plate));
                            local color   = getVehicleColor(vehicle)
                            color = tostring(color)

                            if color == "0" then
                                color = "Siyah"
                            elseif color == "1" then
                                color = "Beyaz"
                            else
                                color = "Belirsiz"
                            end

                            brand = ""
                            model = ""

                            if vehShopData then 
                                brand = vehShopData.vehbrand
                                model = vehShopData.vehmodel
                            else
                                brand = getElementData(vehicle, "brand")
								model = getElementData(vehicle, "model")
							end

                            triggerClientEvent(player , "mdc.execute" , player , "vm.tablist[1].vehicles.push({id : "..v.id.." , plate : '"..v.plate.."' , brand : '"..brand.."' , model : '"..model.."' , color : '"..tostring(color).."'}) ")

                        end

                    end
                end
    
            end , connection , "SELECT * FROM vehicles WHERE owner='"..returnValue.id.."'")

            dbQuery(function(qh)

                local res, rows = dbPoll(qh , 0)
    
                if rows > 0 then
                    
                    for k , v in pairs(res) do 
                        
                        if tonumber(v.deleted) == 0 then

                            local type = tostring(v.type)
                            
                            if type == "0" then
                                type = "Ev"
                            else
                                type = "İşyeri"
                            end
                            
                            local interior = general:getInterior(v.id)
                            if interior then 
                                local zone = getElementZoneName(interior)
                                triggerClientEvent(player , "mdc.execute" , player , "vm.tablist[2].interiors.push({id : "..v.id.." , name : '"..tostring(v.name).."' , zone : '"..zone.."', tip : '"..tostring(type).."'}) ")
                            end
                        end

                    end

                end
    
            end , connection , "SELECT * FROM interiors WHERE owner='"..returnValue.id.."'")
        
            if records[returnValue.id] then 

                for k , v in ipairs(records[returnValue.id]) do 
                    triggerClientEvent(player , "mdc.execute" , player , "vm.tablist[3].records.push({crime : '"..v.reason.."' , date : '"..v.date.."'}) ")
                end

            end


        end , 500 , 1)

    end

end

--[[
Interior types:
TYPE 0: House
TYPE 1: Business
TYPE 2: Government (Unbuyable)
TYPE 3: Rentable
--]]


addEventHandler("onResourceStart" , resourceRoot , function()
    accounts:loadAccounts();
    dbQuery(wanteds.loadWanteds , connection , "SELECT * FROM mdc_wanteds");
    dbQuery(records.loadRecords , connection , "SELECT * FROM mdc_records");
end)