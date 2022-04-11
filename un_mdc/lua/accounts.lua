accounts = setmetatable({}, {
    __index = general,
    __newindex = function(table , key , value)
        general[key] = value;
    end
})

accounts.permissions = {
    ["sourcelua"] = true,
    ["sourcelua1"] = true,
}

accounts.loadAccounts = function()

    dbQuery(function(qh)

        local res, rows = dbPoll(qh , 0)

        if rows > 0 then

            for key , row in pairs(res) do 
                accounts[row.username] = {
                    password = row.password
                }
            end

        end

    end , connection , "SELECT * FROM mdc_accounts")

end

accounts.checkLogin = function(username, password)

    if not accounts[username] then
        return outputChatBox("[!]#ffffff Kullanıcı adın hatalı!" , source , 255 , 0 , 0 , true)
    end

    if tostring(password) ~= accounts[username]["password"] then
        return outputChatBox("[!]#ffffff Şifre yanlış!" , source , 255 , 0 , 0 , true)
    end

    triggerClientEvent(source , "mdc.execute" , source , "vm.page = 'question'")

end
addEvent("mdc.login" , true)
addEventHandler("mdc.login" , root , accounts.checkLogin)

addCommandHandler("mdcaddaccount", function(player, cmd, username , password, repassword)

    if accounts.permissions[player:getData("account:username")] then

        if not username or not password or not repassword then outputChatBox("KULLANIM : /"..cmd.." [KULLANICI ADI] [ŞİFRE] [TEKRAR-ŞİFRE]",player,254,194,14,true) return end

        if accounts[tostring(username)] then
            return outputChatBox("[!]#ffffff Böyle bir kullanıcı adı zaten mevcut!" , player , 255 , 0 , 0 , true)
        end

        if tostring(password) ~= tostring(repassword) then
            return outputChatBox("[!]#ffffff Şifreler eşleşmiyor!" , player , 255 , 0 , 0 , true)
        end

        local exec = dbExec(connection , "INSERT INTO mdc_accounts SET username='"..tostring(username).."', password='"..tostring(password).."'")
        
        if exec then
            accounts[tostring(username)] = {
                username = tostring(username),
                password = tostring(password)
            }
            return outputChatBox("[!]#ffffff Hesap başarıyla aktif edildi!" , player , 0 , 255 , 0 , true)
        end

    end

end)