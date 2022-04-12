local getZoneNameEx = function(x, y, z)
	local zone = getZoneName(x, y, z)
	if zone == 'East Beach' then
		return 'Bayrampaşa'
	elseif zone == 'Ganton' then
		return 'Bağcılar'
	elseif zone == 'East Los Santos' then
		return 'Bayrampaşa'
	elseif zone == 'Las Colinas' then
		return 'Çatalca'
	elseif zone == 'Jefferson' then
		return 'Esenler'
	elseif zone == 'Glen Park' then
		return 'Esenler'
	elseif zone == 'Downtown Los Santos' then
		return 'Kağıthane'
	elseif zone == 'Commerce' then
		return 'Beyoğlu'
	elseif zone == 'Market' then
		return 'Mecidiyeköy'
	elseif zone == 'Temple' then
		return '4. Levent'
	elseif zone == 'Vinewood' then
		return 'Kemerburgaz'
	elseif zone == 'Richman' then
		return '4. Levent'
	elseif zone == 'Rodeo' then
		return 'Sarıyer'
	elseif zone == 'Mulholland' then
		return 'Kemerburgaz'
	elseif zone == 'Red County' then
		return 'Kemerburgaz'
	elseif zone == 'Mulholland Intersection' then
		return 'Kemerburgaz'
	elseif zone == 'Los Flores' then
		return 'Sancak Tepe'
	elseif zone == 'Willowfield' then
		return 'Zeytinburnu'
	elseif zone == 'Playa del Seville' then
		return 'Zeytinburnu'
	elseif zone == 'Ocean Docks' then
		return 'İkitelli'
	elseif zone == 'Los Santos' then
		return 'İstanbul'
	elseif zone == 'Los Santos International' then
		return 'Atatürk Havalimanı'
	elseif zone == 'Jefferson' then
		return 'Esenler'
	elseif zone == 'Verdant Bluffs' then
		return 'Rümeli Hisarı'
	elseif zone == 'Verona Beach' then
		return 'Ataköy'
	elseif zone == 'Santa Maria Beach' then
		return 'Florya'
	elseif zone == 'Marina' then
		return 'Bakırköy'
	elseif zone == 'Idlewood' then
		return 'Güngören'
	elseif zone == 'El Corona' then
		return 'Küçükçekmece'
	elseif zone == 'Unity Station' then
		return 'Merter'
	elseif zone == 'Little Mexico' then
		return 'Taksim'
	elseif zone == 'Pershing Square' then
		return 'Taksim'
	elseif zone == 'Las Venturas' then
		return 'Edirne'
	else
		return zone
	end
end

addCommandHandler('p', function(thePlayer, cmd, ...)
    if thePlayer:getData('called') or thePlayer:getData('caller') then
        if (...) then
            local message = table.concat({...}, " ")
            if thePlayer:getData('call.services') then
                global:sendLocalText(thePlayer, '#D0D0D0(Telefon) '..thePlayer.name:gsub("_"," ")..': '..message, 196, 255, 255)
                thePlayer:outputChat('[!]#D0D0D0 İhbar gönderdiniz, lütfen sabırla bekleyin.',195,184,116,true)
                if thePlayer:getData('call.num') == 155 then
                    for _, p in ipairs(getPlayersInTeam(getTeamFromName ("İstanbul Emniyet Müdürlüğü"))) do
                        p:outputChat('#6464FF[!]#8B8B8E (CH: 155) '..thePlayer:getData('lastPhoneId')..' telefon numarasıyla bir ihbar geldi.',0,0,0,true)
                        p:outputChat('#6464FF[!]#8B8B8E (CH: 155) İhbar: '..message,0,0,0,true)
                        p:outputChat('#6464FF[!]#8B8B8E (CH: 155) Lokasyon: '..getZoneNameEx(thePlayer.position.x, thePlayer.position.y, thePlayer.position.z),0,0,0,true)
                        triggerClientEvent(p,"walkie.sound",p)
                    end
                elseif thePlayer:getData('call.num') == 156 then
                    for _, p in ipairs(getPlayersInTeam(getTeamFromName ("İstanbul İl Jandarma Komutanlığı"))) do
                        p:outputChat('#6464FF[!]#8B8B8E (CH: 156) '..thePlayer:getData('lastPhoneId')..' telefon numarasıyla bir ihbar geldi.',0,0,0,true)
                        p:outputChat('#6464FF[!]#8B8B8E (CH: 156) İhbar: '..message,0,0,0,true)
                        p:outputChat('#6464FF[!]#8B8B8E (CH: 156) Lokasyon: '..getZoneNameEx(thePlayer.position.x, thePlayer.position.y, thePlayer.position.z),0,0,0,true)
                        triggerClientEvent(p,"walkie.sound",p)
                    end
                elseif thePlayer:getData('call.num') == 112 then
                    for _, p in ipairs(getPlayersInTeam(getTeamFromName ("İstanbul Devlet Hastanesi"))) do
                        p:outputChat('#5F5F5F[!]#D55858 (CH: 112) '..thePlayer:getData('lastPhoneId')..' telefon numarasıyla bir ihbar geldi.',0,0,0,true)
                        p:outputChat('#5F5F5F[!]#D55858 (CH: 112) İhbar: '..message,0,0,0,true)
                        p:outputChat('#5F5F5F[!]#D55858 (CH: 112) Lokasyon: '..getZoneNameEx(thePlayer.position.x, thePlayer.position.y, thePlayer.position.z),0,0,0,true)
                        triggerClientEvent(p,"walkie.sound",p)
                    end
                end
                thePlayer:setData('call.services', nil)
                thePlayer:setData('called', nil)
                thePlayer:setData('caller', nil)
                thePlayer:setData('call.num', nil)
                thePlayer:setData('callTarget', nil)
            else
                local targetPlayer = thePlayer:getData('callTarget') or nil
                if targetPlayer then
                    if thePlayer:getData('callWaiting') then
                        thePlayer:outputChat('[!]#D0D0D0 Karşı tarafın aramayı kabul etmesini bekleyin.',195,184,116,true)
                    else
                        global:sendLocalText(thePlayer, '#D0D0D0(Telefon) '..thePlayer.name:gsub("_"," ")..': '..message, 196, 255, 255)
                        targetPlayer:outputChat('#D0D0D0Telefon: '..message,195,184,116,true)
                    end
                else
                    thePlayer:outputChat('[!]#D0D0D0 Herhangi bir telefon görüşmesinde değilsin.',195,184,116,true)
                end
            end
        else
            thePlayer:outputChat('[!]#D0D0D0 /'..cmd..' Text',195,184,116,true)
        end
    end
end)