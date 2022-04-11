addEvent('black.market.give', true)
addEventHandler('black.market.give', root, function(cash, weaponid)
  local playerTeam = getPlayerTeam(source)
  local playerTeamType = getElementData(playerTeam, "type")
  local playerTeamLevel = getElementData(playerTeam, "birlik_level")
  if playerTeamType == 1 or playerTeamType == 0 then
    if playerTeamLevel > 3 then
      if tonumber(cash) and tonumber(weaponid) then
        if source:getData('loggedin') == 1 then
          if exports.un_global:takeMoney(source, cash) then
            local mySerial = exports.un_global:createWeaponSerial(1, getElementData(source, "dbid"), getElementData(source, "dbid"))
            exports.un_global:giveItem(source, 115, weaponid..":"..mySerial..":"..getWeaponNameFromID(weaponid).."::")
            triggerEvent("updateLocalGuns", source)
            source:outputChat('[!]#ffffff (₺'..cash..' ödeyerek başarıyla satın aldınız.',255,0,0,true)
          else
            source:outputChat('[!]#ffffff Üzerinizde yeteri kadar para yok.',255,0,0,true)
          end
        end
      end
    else
      source:outputChat('[!]#ffffff Blackmarketi kullanmak için birliğinizin 3 seviyeden fazla olması gerekir.',255,0,0,true)
    end
  else
    source:outputChat('[!]#ffffff İllegal bir birliğe dahil değilsiniz.',255,0,0,true)
  end
end)