

-- Class SuperObject allow recursive calls of overriden methods

--[[

	--Usage:

	-- subclass of SuperObject
	MyClass = class("MyClass",SuperObject)
	MyClass:someMethod = function() print("someMethod") end
	
	-- subclass of your class
	MySubclass = class("MySubclass",MyClass)
	
	-- call super in overriden method
	MySubclass:someMethod = function ()
		self:super("someMethod")
	end
	
--]]

SuperObject = class("SuperObject")

local __instance__ = {count=0,classes={}}

function SuperObject:initialize()
	--print("SuperObject:initialize()")
	__instance__.count = __instance__.count + 1
	if (__instance__.classes[self.class.name] == nil) then
		__instance__.classes[self.class.name] = 1
	else
		__instance__.classes[self.class.name] = __instance__.classes[self.class.name] + 1
	end
	self.__instance__ = __instance__.classes[self.class.name]
	--print("SuperObject initialize",self )
end
--[[
function SuperObject:__call(_,...)
	return SuperObject:new(...)
end
--]]
function SuperObject:__tostring()
	
	local mt = getmetatable(self)
	local ts = mt.__tostring
	mt.__tostring = nil
	local ov = tostring(self)
	rawset(mt,"__tostring",ts)
	
	return "instance of " .. self.class.name .. 
				" # " .. tostring( self.__instance__ ) ..
				" / " .. tostring(__instance__.classes[self.class.name]) ..
				 " (".. tostring(__instance__.count) .. ")" ..
				" [" .. ov .. "]"
	--return 
end

function SuperObject:instancesCount()
	return __instance__.classes[self.class.name]
end

function SuperObject:destroy()

	--print("SuperObject destroy",self )

	__instance__.count = __instance__.count - 1
	__instance__.classes[self.class.name] = __instance__.classes[self.class.name] - 1
	
	-- need this or not?
	setmetatable(self,nil)
	for k,v in pairs(self) do
		rawset(self,k,nil)
	end
	self = nil
end

local __super__ = setmetatable({}, {__mode = "k"}) -- weak table
--local __super__ = {instance=nil,method=nil,deepth=0}

function SuperObject:super(method,...)
	
	--print("Call SuperMethod" , method , " in " ,self)
	
	local __instance__ = __super__[self]
	
	if (__instance__ == nil) then
		--print("first time super call for ",self)
		__instance__ = {}
		__super__[self] = __instance__
	end
	
	local __deepth__ = __instance__[method]
	
	if(__deepth__ == nil) then
		--print("first time super method " , method , "call for" , self)
		__deepth__ = 1
		__instance__[method] = __deepth__
	else
		__deepth__ = __deepth__ + 1
		__instance__[method] = __deepth__
	end
	
	local s = self.class
	
	local i = __deepth__

	local f = s[method]

	while i>0 do
		--print(i,"METHOD",s,s[method])
		if (f == s[method]) then
			s = s.superclass
		else
			f = s[method]
			i = i - 1
		end
	
	end
	
	
	if (f) then	 
		--print("SuperMethod found in class " , s , " on " , self.class)
		return f(self,...)
	else
		--print("SuperMethod not found in class " , s , " on " , self.class)
		__instance__[method] = nil
	end

end