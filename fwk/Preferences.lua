

PreferencesClass = class("PreferencesClass",SuperObject)

PreferencesClass.DEFAULT = ""

-- Singleton implementation

local __SE__ = {} -- singletonEnforcer

-- PreferencesClass 
	
function PreferencesClass:initialize(se)
	
	if(se == __SE__ and PreferencesClass.PreferencesClass == nil) then
		print("!! PreferencesClass instance creation")
		
		self:super("initialize")
		
	else
		error("Only ONE instance of a PreferencesClass can be created, use PreferencesClass.PreferencesClass")
	end

end

--loging
function PreferencesClass:readPreferences()
	
end

-- Preferences Instancing
Preferences = {}

local PreferencesInstance = PreferencesClass(__SE__)

print()
print("Preferences: ", PreferencesInstance)

local mt = {}

mt.__index = function(t,k) 
	return PreferencesInstance[k]
end

mt.__newindex = function(t,k,v)
	error("Preferences can't be changed")
end

setmetatable(Preferences,mt)
