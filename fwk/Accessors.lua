-----------------------------------------------------------------------------------
-- Accessors.lua
-- Flop ( ) - 14 Feb 2011
-- mixin that includes acessors 
-----------------------------------------------------------------------------------

--[[ Usage:

  require 'middleclass' -- or similar
  require 'Accessors'  -- or similar


]]

assert(Object~=nil and class~=nil, 'MiddleClass not detected. Please require it before using Accessors')


--local _metamethods = { -- all metamethods except __index
--  '__add', '__call', '__concat', '__div', '__le', '__lt', '__mod', '__mul', '__pow', '__sub', '__tostring', '__unm' 
--}

-- make the class index-aware. Otherwise, index would be a regular method
local function _modifyClass(theClass)

	
	--print("MODIFY " , theClass)

	-- if callbacks was used - use dicrionarry created by Callbacks
	local classDict = theClass.__callbacksDict or theClass.__classDict
	

	local instanceDict = {}

	-- copy all old fileds from class to new table
	for k,v in pairs(classDict) do
		--print("COPY",k,v)
		instanceDict[k] = v
	end
	
	--create table for contains properties
	
	instanceDict.__accessors = {}
	instanceDict.__index__ = instanceDict.__index
	instanceDict.__newindex__ = instanceDict.__newindex

	rawset(theClass, '__accessorsDict', instanceDict)

	
	local superInstanceDict = rawget(theClass.superclass, '__accessorsDict')
	if (superInstanceDict and superInstanceDict.__accessors) then
		-- copy super class properties
		for k,v in pairs(superInstanceDict.__accessors) do
			instanceDict.__accessors[k] = v
		end
		
	end
	
	instanceDict.__index = function(instance, name)
		--print(" --- get " , name)
		local t = instanceDict.__accessors[name]
		if(t) then
			local getter = instance["get_"..name] 
			--print(" --- get for asessor",getter)
			if (getter) then return getter(instance) end
			return rawget(instance, "_"..name)
		else
			return instanceDict.__index__(instance,name)
		end
	end
	
	instanceDict.__newindex = function(instance, name, value) 
		--print(" --- set " , name)
		local t = instanceDict.__accessors[name]
		if(t) then
			assert(t.readonly == nil, "property : " .. name .. " is read only")
			local setter = instance["set_"..name] 
			if (setter) then 
				setter(instance,value)
			else
				rawset(instance, "_"..name, value)
			end
			
		else
			--instanceDict.__newindex__(instance, name, value)
			if(type(value) == "function") then
				--print("recreate function ", name , value)
				--instance[name] = value --infine loop here
				
				rawset(instance, name, value)
			else
				--print("rawset value ", name , value)
				rawset(instance, name, value)
			end
		end
	end
	

	


	--modify the instance creator so instances use __instanceDict and not __classDict
	function theClass:new(...)
		assert(subclassOf(Object, self), "Use class:new instead of class.new")
		local instance = setmetatable({ class = theClass }, theClass.__accessorsDict)
		local t = instanceDict.__accessors

		for name,v in pairs(t) do
			if (classDict["set_"..name] == nil) then 
				rawset(instance, "_"..name, v.init)
			end
		end
		local init = instance.initialize
		
		--print("@@@ NEW",init,theClass)
		instance.initialize(instance,...)

		for name,v in pairs(t) do
			
			local setter = instance["set_"..name]
			if (setter and (v.init ~= nil)) then 
				setter(instance,v.init)
			end
		end
		return instance

	end

	--[[
	local oldNew = theClass.new
  theClass.new = function(theClass, ...)
    local instance = oldNew(theClass, ...)
    setmetatable(instance, theClass.__instanceDictA)
    return instance
  end

	print("@@@ OLD",oldNew)

  
	
	
	--]]

end

Accessors = {}

function Accessors:included(theClass) 
	
	print(" ### include Acessors in ",theClass)

  	if not includes(Callbacks, theClass) then
    	theClass:include(Callbacks)
  	end
	
	if includes(Accessors, theClass) then print("Accessors included in" , theClass) return end
  


	-- modify the class
	_modifyClass(theClass)
  
	-- modify all future subclases of theClass the same way
	local prevSubclass = theClass.subclass
	
	theClass.subclass = function(aClass, name, ...)
		local theSubClass = prevSubclass(aClass, name, ...)
		_modifyClass(theSubClass)
		return theSubClass
	end
end

function Accessors.access(aClass,propName,init,readonly) 
	assert(type(propName)=='string', 'prop must be a string')

	local accessors = aClass.__accessorsDict.__accessors
	accessors[propName] = {init = init,readonly=readonly}
	
end