


Button = class("Button",Clip)

Button.CLICK = "onClick"
Button.PRESS = "onPress"
Button.RELEASE = "onRelease"
Button.CANCEL = "onCancel"
Button.DRAG = "onDrag"
Button.DRAG_OUT = "onDragOut"
Button.DRAG_IN = "onDragIn"
Button.STATE_CHANGE = "onStateChange"


Button.STATE_NORMAL = "STATE_NORMAL"
Button.STATE_PRESSED = "STATE_PRESSED"
Button.STATE_DISABLED = "STATE_DISABLED"
Button.STATE_SELECTED = "STATE_SELECTED"
Button.STATE_SELECTED_PRESSED = "STATE_SELECTED_PRESSED"


Button:access("state",Button.STATE_NORMAL,true)
Button:access("pressed",false,true)
Button:access("hovered",false,true)

Button:access("selected",false)
Button:access("enabled",true)

Button:access("stateFrames",nil,true)
Button:access("transparentTouch",false)


function Button:initialize(...)
	self:super("initialize",...)
	self:addEventListener("touch",self.onTouchEvent,self)
	
	self._stateFrames = {} 
	self._stateFrames[Button.STATE_NORMAL] = 1
	self._stateFrames[Button.STATE_PRESSED] = 1
	self._stateFrames[Button.STATE_DISABLED] = 1
	self._stateFrames[Button.STATE_SELECTED] = 1
	self._stateFrames[Button.STATE_SELECTED_PRESSED] = 1
	
	if (self.framesCount >= 2) then 
		self._stateFrames[Button.STATE_PRESSED] = 2
	end
	
	if (self.framesCount >= 3) then 
		self._stateFrames[Button.STATE_DISABLED] = 3
	end	

	if (self.framesCount == 4) then 
		self._stateFrames[Button.STATE_DISABLED] = 1
		self._stateFrames[Button.STATE_SELECTED] = 3
		self._stateFrames[Button.STATE_SELECTED_PRESSED] = 4
	end
	
	if (self.framesCount == 5) then 
		self._stateFrames[Button.STATE_SELECTED] = 4
		self._stateFrames[Button.STATE_SELECTED_PRESSED] = 5
	end	
	--self._state = Button.STATE_NORMAL
	--self._selected = false
	--self._enabled = true
end

function Button:initGraphics()
	self:super("initGraphics")
	self.sprite:pause()
end

function Button:get_selected()
	return self._selected
end
function Button:set_selected(value)
	self._selected = value
	self:switchView()
end

function Button:get_enabled()
	return self._enabled
end
function Button:set_enabled(value)
	--print("Button:set_enabled",value)
	self._enabled = value
	self:switchView()
end

function Button:switchView()

	if self.enabled then
		self._sprite.alpha = 1
		if self.selected then
			if self.pressed and self.hovered then
				self._state = Button.STATE_SELECTED_PRESSED
			else
				self._state = Button.STATE_SELECTED
			end
		else
			if self.pressed and self.hovered then
				self._state = Button.STATE_PRESSED
			else
				self._state = Button.STATE_NORMAL
			end
		end
	else
		self._state = Button.STATE_DISABLED
		if (self.framesCount <= 2) then
			self._sprite.alpha = 0.5
		end
	end
	self.currentFrame = self.stateFrames[self.state]
	--print("switchView", self.state, self.stateFrames[self.state], self.currentFrame)
	
	--self:dispatchEvent({name=Button.STATE_CHANGE,state=self.state})
end


function Button:onTouchEvent(event)

	if(self.enabled == false) then return end

	local e1 = {}
	local e2 = {}
	
	for k,v in pairs(event) do
		e1[k] = v
		e2[k] = v
	end 
	
	e1.xLocal, e1.yLocal = self.displayObject:contentToLocal(event.x,event.y)
	e1.xParent, e1.yParent = self.displayObject.parent:contentToLocal(event.x,event.y)
	e1.name = nil
	e2.xLocal, e2.yLocal = self.displayObject:contentToLocal(event.x,event.y)
	e2.xParent, e2.yParent = self.displayObject.parent:contentToLocal(event.x,event.y)
	e2.name = nil
	
	--print(e.phase,e.xLocal,e.yLocal,e.xParent,e.yParent)
	
	if event.phase == "began" then

		e1.name = Button.PRESS
		
		if (self.pressed == false) then 
			self._pressed = true
			self._hovered = true
			display.getCurrentStage():setFocus(event.target,event.id)
		end

		self:switchView()
		
	elseif event.phase == "moved" then

		e1.name = Button.DRAG
		
		if (self.pressed) then
		
			if (self.hovered) then
				if (self:hitTestEvent(event) == false) then
					self._hovered = false
					self:switchView()	
					e2.name = Button.DRAG_OUT
					
				end
			else
				if (self:hitTestEvent(event) == true) then
					self._hovered = true
					self:switchView()
					e2.name = Button.DRAG_IN
				end
			end
			
		end
		
    elseif event.phase == "ended" then

		e1.name = Button.RELEASE
		
		if (self.pressed) then 
			
			display.getCurrentStage():setFocus(nil)
			if (self:hitTestEvent(event)) then
				e2.name = Button.CLICK 
			end			
		end
		
		self._pressed = false
		self:switchView()

		
	elseif event.phase == "cancelled" then
		
		if (self.pressed) then 
			self._pressed = false
			display.getCurrentStage():setFocus(nil)
			e1.name = Button.RELEASE 
		end

		e2.name = Button.CANCEL 
		
		self:switchView()

		
    end
	
	if (e1.name) then
		self:dispatchEvent(e1)
	end

	if (e2.name) then
		self:dispatchEvent(e2)
	end
	
	--print("TOUSH IN",self)	
	return not self._transparentTouch
	
end

