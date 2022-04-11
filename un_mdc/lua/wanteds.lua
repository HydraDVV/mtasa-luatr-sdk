wanteds = setmetatable({}, {
    __index = general,
    __newindex = function(table , key , value)
        general[key] = value;
    end
})

wanteds["ranked"] = {}

wanteds.loadWanteds = function(qh)
    
    local res, rows = dbPoll(qh , 0)
    wanteds["ranked"] = {
        ["player"] = {},
        ["vehicle"] = {},
    }

    if rows > 0 then

        local rankTable    = {}
        local rankCount    = 0
        local rankBoundary = 0

        for key , row in pairs(res) do 

            local type = tostring(row.type)
            if not wanteds["ranked"][type][row.id] then
                wanteds["ranked"][type][row.id] = {
                    id     = row.id,
                    count  = 0,
                    name   = row.name,
                    plate  = row.plate,
                    reason = row.reason,
                    date   = row.date,
                    type   = row.type
                }
            end

            wanteds["ranked"][type][row.id].count = wanteds["ranked"][type][row.id].count+1
            wanteds["ranked"][type][row.id].date  = row.date

            if rankCount < wanteds["ranked"][type][row.id].count then
                rankCount = wanteds["ranked"][type][row.id].count
            end

            if type == "player" then 
                rankTable[row.id] = wanteds["ranked"][type][row.id]
            end

        end

        local executeText = ""

        for i=rankCount,1,-1  do 
            if rankBoundary >= 10 then 
                break
            end
            for key , index in pairs(rankTable) do 
                if index.count == i then 
                    table.remove(rankTable , key)
                    rankBoundary = rankBoundary + 1
                    executeText = executeText.." {rank : "..rankBoundary.." , name : '"..index.name.."' , crime : '"..index.reason.."' , date : '"..index.date.."'},"
                end
            end
        end

        setTimer(function()
            triggerClientEvent(root , "mdc.execute" , root , "vm.wanteds = ["..executeText.."]")
        end , 1500 , 1)

        return true
    end

    return false

end