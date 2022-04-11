local sx , sy = guiGetScreenSize()

local cbrowser = guiCreateBrowser(0,0 , sx , sy , true , true , false)
local browser  = guiGetBrowser(cbrowser)

if cbrowser then   
    addEventHandler('onClientBrowserCreated', cbrowser,function()
        loadBrowserURL(source , "http://mta/local/index.html")
    end)
end
showCursor(false)
guiSetVisible(cbrowser , false)

addEvent("mdc.login" , true)
addEventHandler("mdc.login" , root , function(username , password)
    triggerServerEvent("mdc.login" , localPlayer , username, password)
end)

addEvent("mdc.execute" , true)
addEventHandler("mdc.execute" , root , function(execute)
    executeBrowserJavascript(browser , execute)
end)

addEvent("mdc.close" , true)
addEventHandler("mdc.close" , root , function()
    showCursor(false)
    guiSetInputEnabled(false)
    guiSetVisible(cbrowser , false)
end)

addEvent("mdc.question" , true)
addEventHandler("mdc.question" , root , function(input, vehicle , home)
    
    local type = ""

    if tonumber(vehicle) == 1 then
        type = "vehicle"
    elseif tonumber(home) == 1 then
        type = "interior"
    else
        type = "personel"
    end

    executeBrowserJavascript(browser, "vm.tablist[1].vehicles  = []");
    executeBrowserJavascript(browser, "vm.tablist[2].interiors = []");
    executeBrowserJavascript(browser, "vm.tablist[3].records   = []");

    triggerServerEvent("mdc.question" , localPlayer , type , input)
    
end)

addEvent("mdc.insert" , true)
addEventHandler('mdc.insert' , root , function(found , reason , checkbox)

    checkbox = tonumber(checkbox) == 1 and "record" or "wanted"
    triggerServerEvent("mdc.insert" , localPlayer , found , checkbox , reason)

end)


addCommandHandler("mdc" , function()

    if localPlayer:getData("faction") == 1 then

        executeBrowserJavascript(browser, "vm.tablist[1].vehicles  = []");
        executeBrowserJavascript(browser, "vm.tablist[2].interiors = []");
        executeBrowserJavascript(browser, "vm.tablist[3].records   = []");
        executeBrowserJavascript(browser, "vm.page = 'login'");

        showCursor(false)
        guiSetInputEnabled(not guiGetInputEnabled())
        guiSetVisible(cbrowser , not guiGetVisible(cbrowser))

    end

end)