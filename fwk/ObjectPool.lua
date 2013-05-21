-----------------------------------------------------------------------------------
-- ObjectPool.lua
-- Flop ( ) - 14 Feb 2011
-- mixin that includes acessors 
-----------------------------------------------------------------------------------

--[[ Usage:

  require 'middleclass' -- or similar
  require 'ObjectPool'  -- or similar


]]

assert(Object~=nil and class~=nil, 'MiddleClass not detected. Please require it before using ObjectPool')




local function _modifyClass(theClass)

	local classDict = theClass.__accessorsDict or theClass.__callbacksDict or theClass.__classDict
	

	print("MODIFY " , theClass)
	
	-- must be defined in class:
	-- theClass.poolPull
	-- theClass.poolPush
	assert(theClass.poolPush ~= nil and theClass.poolPull ~= nil , "poolPush anf poolPull function must be defined in class before include ObjectPool", theClass)

	-- can be defined in the class:
	-- theClass.poolInit
	
	if theClass.poolInit == nil then
		theClass.poolInit = function(instance,...)
			--print("poolInit deffault call same as pull")
			instance.poolPull(instance,...)
		end
	end

	-- pool table
	theClass.__pool__ = {}


	--modify the instance to use pool when objects exists
	local onew = theClass.new
	
	function theClass:new(...)
		local instance
		--local instance = setmetatable({ class = theClass }, classDict)
		--instance.initialize(instance,...)
		if (#theClass.__pool__ > 0) then
			print("get Fom pool ", #theClass.__pool__)
			instance = table.remove(theClass.__pool__)
			instance.poolPull(instance,...)
		else
			print("create new")
			instance = onew(theClass,...)	
			instance.poolInit(instance,...)
		end
		
		return instance
	end

	theClass.poolKill = function(instance,...)
		--print("call destroy to pool")
		instance.poolPush(instance)
		table.insert(theClass.__pool__,instance)
	end	
	
	theClass.poolLen = function()
		return #theClass.__pool__
	end
	
	theClass.poolFill = function(number,...)
		theClass.poolFilling = true
		local c = {}
		while (#c < number) do
			local i = theClass:new(...)
			table.insert(c,i)
		end
		while (#c > 0) do
			local i = table.remove(c)
			i:poolKill()
		end
		theClass.poolFilling = nil
	end
	
	theClass.poolClear = function()
		while (#theClass.__pool__ > 0) do
			instance = table.remove(theClass.__pool__)
			theClass.destroy(instance)
		end
	end
	

end

ObjectPool = {}

function ObjectPool:included(theClass) 
	
	-- do nothing if the mixin is already included
	if includes(ObjectPool, theClass) then return end
	
	print(" ### include ObjectPool in ",theClass)
	
	-- modify the class
	_modifyClass(theClass)

end


