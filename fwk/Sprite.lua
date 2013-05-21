

--require("src/fwk/Accessors")

--Sprite here

require("src.fwk.SuperObject")

Sprite = class("Sprite",SuperObject)


Sprite:include(Branchy)
Sprite:after("destroy")

Sprite:include(Accessors)


--Sprite:include(Indexable)



Sprite:access("x")
Sprite:access("y")

Sprite:access("xScale")
Sprite:access("yScale")

Sprite:access("alpha")
Sprite:access("rotation")
Sprite:access("visible")
--Sprite:access("isFocus")
Sprite:access("displayObject",nil,true)

--Sprite:include(Callbacks)

--Sprite:include(GetterSetter)
--Sprite:include(Indexable)



function Sprite:initialize()

	--print("Sprite:initialize()")
	self:super("initialize")
	
	self._listeners = {}
	self._displayObject = display.newGroup()

	--self._displayObject.x = self._x or self._displayObject.x
	--self._displayObject.y = self._y or self._displayObject.y
	--self._displayObject.sprite = self --link to self from group
	Stage:spriteToHidden(self)
	self:initGraphics()

end

function Sprite:set_x(value)
	self._displayObject.x = value
end
function Sprite:get_x()
	return self._displayObject.x
end

function Sprite:set_y(value)
	self._displayObject.y = value
end
function Sprite:get_y()
	return self._displayObject.y
end

function Sprite:set_xScale(value)
	self._displayObject.xScale = value
end
function Sprite:get_xScale()
	return self._displayObject.xScale
end

function Sprite:set_yScale(value)
	self._displayObject.yScale = value
end
function Sprite:get_yScale()
	return self._displayObject.yScale
end

function Sprite:set_rotation(value)
	self._displayObject.rotation = value
end
function Sprite:get_rotation()
	return self._displayObject.rotation
end

function Sprite:set_visible(value)
	self._displayObject.isVisible = value
end
function Sprite:get_visible()
	return self._displayObject.isVisible
end


function Sprite:set_alpha(value)
	self._displayObject.alpha = value
end
function Sprite:get_alpha()
	return self._displayObject.alpha
end

function Sprite:initGraphics()
	--print("Sprite:initGraphics" , self)
end

function Sprite:addChildAt(child,index)
	-- TODO fix child counter and related stuff
	assert(instanceOf(Sprite,child) , tostring(child) .. " is not instance of Sprite class")
	local added = Branchy.addChild(self,child)
	self._displayObject:insert(index,child.displayObject)

end

function Sprite:addChild(child)

	assert(instanceOf(Sprite,child) , tostring(child) .. " is not instance of Sprite class")
	local added = Branchy.addChild(self,child)
	self._displayObject:insert(child.displayObject)
end

function Sprite:removeChild(child)
	assert(instanceOf(Sprite,child) , tostring(child) .. " is not instance of Sprite class")
	Branchy.removeChild(self,child)
	Stage:spriteToHidden(child)
end

-- EventDispatcher for Sprite
local function getHandlerName(name,handler)
	return "_handler_"..name.."_"..tostring(handler):sub(13)
end

local function checkForRuntimeEvent(name,physicalSprite)

	 
	if (name == 'enterFrame' or
		name == 'accelerometer') then
		return true
	elseif	(name == 'collision' or
			name == 'postCollision' or
			name == 'preCollision') then
		return (physicalSprite ~= true)
	else
		return false
	end

	return false
	

end

function Sprite:hasEventListener(name,listener)
	return self._listeners[getHandlerName(name,listener)] ~= nil
end


function Sprite:addEventListener(name,listener,context,replace,...)
	assert(type(name) == 'string' ,"event name must be a string "..type(name).." was provided")
	assert(type(listener) == 'function' ,"event handler must be a function "..type(listener).." was provided")
	
	if (self._listeners[getHandlerName(name,listener)]) then
		assert(replace ,"event listener already exist use replace flag for replace")
		self:removeEventListener(name,self._listeners[getHandlerName(name,listener)])
	end
	
	--print(" ----- ADD LISTENER " , name , listener)
	
	local table = {}
	
	table['__eventName'] = name
	table['__handlerName'] = getHandlerName(name,listener)
	table['__listenerFunc'] = listener
	table['__context'] = context or self
	table['__params'] = ...

	
	table[name] = function(tbl,evt)
		
		local __listenerFunc = tbl['__listenerFunc']
		local __context = tbl['__context']
		local __params = tbl['__params']

		
		--print("Event trigged " ,self, tbl,__listenerFunc,__environment) 
		
		return __listenerFunc(__context,evt,__params)
		--return true
	end
	
	self._listeners[getHandlerName(name,listener)] = table
	
	if (checkForRuntimeEvent(name,self._physicalSprite)) then
		Runtime:addEventListener(name,table)
	else
		self.displayObject:addEventListener(name,table)
	end
	
end

function Sprite:removeEventListener(name,listener)

	assert(type(name) == 'string' ,"event name must be a string "..type(name).." was provided")
	assert(type(listener) == 'function' ,"event handler must be a function "..type(listener).." was provided")
	
	local table = self._listeners[getHandlerName(name,listener)]
	
	if (checkForRuntimeEvent(name)) then
		Runtime:removeEventListener(name,table)
	else
		self.displayObject:removeEventListener(name,table)
	end
	self._listeners[getHandlerName(name,listener)] = nil 
end


function Sprite:removeAllEventListeners()
	for key,table in pairs(self._listeners) do
		self:removeEventListener(table['__eventName'],table['__listenerFunc'])
	end
	self._listeners = {}	
end

function Sprite:dispatchEvent(event)
	--print("Sprite dispatch event :",event,event.name)
	event.target = self
	self.displayObject:dispatchEvent( event )
end



function Sprite:hitTestEvent(event)
	return self:hitTest(event.x,event.y)	
end

function Sprite:hitTest(x,y)
	local bounds = self.displayObject.contentBounds
	if ( x>=bounds.xMin and x<=bounds.xMax and y>=bounds.yMin and y<=bounds.yMax) then
		return true
	end
	
	return false
end

function Sprite:removeSelf()
	
	if (self.parent) then
		self.parent:removeChild(self)
		self.parent = nil
	end
	
end

function Sprite:clearAllGraphic()
	--destroy every child
	while (#self.children) do
		if (#self.children == 0) then break end
		key = next(self.children)
		local c = self.children[key]
		--print("RMOVE CHILD : ",key,#self.children,c)
		self:removeChild(c)
		c:destroy()
	end

	--clear childs (for Brunchy)
	self:removeAllChildren()

	-- clear rest group
	
	for i = self.displayObject.numChildren,1,-1 do
		self.displayObject[i]:removeSelf()
		self.displayObject[i] = nil
	end
end

function Sprite:destroy()
	
	--print(" # Sprite:destroy() ", self,self.displayObject,self.displayObject.numChildren,#self.children)
	
	--remove group link
	self.displayObject.sprite = nil
	
	--remove all listeners
	self:removeAllEventListeners()
	
	--destroy every child
	while (#self.children) do
		if (#self.children == 0) then break end
		key = next(self.children)
		local c = self.children[key]
		--print("RMOVE CHILD : ",key,#self.children,c)
		self:removeChild(c)
		c:destroy()
	end

	--clear childs (for Brunchy)
	self:removeAllChildren()


	--remove self From displayList
	self:removeSelf()

	-- destroy rest group
	
	for i = self.displayObject.numChildren,1,-1 do
		self.displayObject[i]:removeSelf()
		self.displayObject[i] = nil
	end

	self.displayObject:removeSelf()

	
	--superObject destroy
	self:super("destroy")
	
	-- hack for Branchy it need removeAllChildren() afret destroy
	-- But superObject:destroy() - destroy all include metatables
	--self.removeAllChildren = Object.destroy -- here empty function
	
	
	
end