records = setmetatable({}, {
    __index = general,
    __newindex = function(table , key , value)
        general[key] = value;
    end
})

records = {}

records.loadRecords = function(qh)

    local res, rows = dbPoll(qh , 0)

    if rows > 0 then

        for key , row in pairs(res) do 

            local type = tostring(row.type)

            if not records[row.id] then
                records[row.id] = {}
            end

            table.insert(records[row.id] , {
                id     = row.id,
                name   = row.name,
                plate  = row.plate,
                reason = row.reason,
                date   = row.date,
                type   = row.type,
            })
            
        end

        return true
    end

    return false

end