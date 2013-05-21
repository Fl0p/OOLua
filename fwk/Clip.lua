

require("src.fwk.Sprite")

Clip = class("Clip",Sprite)

Clip:access("name",nil,true)

Clip:access("align",nil,true)
Clip:access("period",nil,true)
Clip:access("loop",nil,true)

Clip:access("sprite",nil,true)
Clip:access("framesCount",0,true)
Clip:access("currentFrame")

function Clip:initialize(name,align,period,loop)
	self._name = name
	self._align = align or 0;
	self._period = period or 100;
	self._loop = loop or 0;
	self:super("initialize")
end

function Clip:get_framesCount()
	return self.sprite.framesCount
end

function Clip:get_currentFrame()
	return self.sprite.currentFrame
end

function Clip:set_currentFrame(value)
	self.sprite.currentFrame = value
end

function Clip:play()
	self.sprite:play()
end

function Clip:pause()
	self.sprite:pause()
end
function Clip:initGraphics()
	
	self._sprite = Atlas:getClipSprite(self.name)

	self.sprite.xScale = 1/Stage.scaleValue
	self.sprite.yScale = 1/Stage.scaleValue
	
	self.displayObject:insert(self._sprite)

	if (self.align == 1) then
		self.sprite.xOrigin = self.sprite.width / 2 / Stage.scaleValue
		self.sprite.yOrigin = self.sprite.height / 2 / Stage.scaleValue
	elseif(self.align == 2) then
		self.sprite.xOrigin = 0
		self.sprite.yOrigin = self.sprite.height / 2 / Stage.scaleValue
	elseif(self.align == 3) then
		self.sprite.xOrigin = -self.sprite.width / 2 / Stage.scaleValue
		self.sprite.yOrigin = self.sprite.height / 2 / Stage.scaleValue
	elseif(self.align == 4) then
		self.sprite.xOrigin = -self.sprite.width / 2 / Stage.scaleValue
		self.sprite.yOrigin = 0
	elseif(self.align == 5) then
		self.sprite.xOrigin = -self.sprite.width / 2 / Stage.scaleValue
		self.sprite.yOrigin = -self.sprite.height / 2 / Stage.scaleValue
	elseif(self.align == 6) then
		self.sprite.xOrigin = 0
		self.sprite.yOrigin = -self.sprite.height / 2 / Stage.scaleValue
	elseif(self.align == 7) then
		self.sprite.xOrigin = self.sprite.width / 2 / Stage.scaleValue
		self.sprite.yOrigin = -self.sprite.height / 2 / Stage.scaleValue
	elseif(self.align == 8) then
		self.sprite.xOrigin = self.sprite.width / 2 / Stage.scaleValue
		self.sprite.yOrigin = 0
	else 
	end


	
	if (self.sprite.framesCount > 1 and self.period ) then
		--print("!!!!!!!!!!!",self.sprite.spriteSet, self.name, self.sprite.startFrame, self.sprite.framesCount, self.period, self.loop)
		sprite.add( self.sprite.spriteSet, self.name, 1, self.sprite.framesCount, self.period, self.loop)
		self.sprite:prepare(self.name)
	end
	
	if (self.sprite.framesCount > 1) then
		self.sprite:play()
	end

end