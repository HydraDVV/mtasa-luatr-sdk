Service = {}
local Service_mt = setmetatable(Service, {
	__call = function(cls, ...)
		local self = {}
		setmetatable(self, {
			__index = cls
		})

		self:constructor(...)
		return self
	end
})

function Service:new(namespace)
	return setmetatable({ namespace = namespace }, Service_mt)
end

function Service:cache(key, value)

	cacheTable = cacheTable or {}
	if not cacheTable[key] then
		cacheTable[key] = value;
	end

return cacheTable[key]
end
