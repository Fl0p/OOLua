
require("src.fwk.Sprite")

Label = class("Label",Sprite)

Label:access("text")
Label:access("color", {r=255,g=255,b=255})
Label:access("font")
Label:access("size")
Label:access("align")

function Label:initialize(text,font,size,algn,color)

	self._text = text or "Label"
	self._font = font or native.systemFont
	self._size = size or 16
	self._align = algn or 0
	self._color = color or self._color
	self:super("initialize")
end

function Label:initGraphics()
	self:super("initGraphics")
	self:recreate()
end
function Label:recreate()

	if (self._txt) then
		self._txt:removeSelf()
	end
	self._txt = display.newText(self.displayObject,"",0,0,self._font,self._size*Stage.scaleValue)
	self:redraw()
end

function Label:redraw()

	--print("LABEL",self._text)
		
	self._txt.text = self._text
	self._txt:setTextColor(self._color.r,self._color.g,self._color.b)
	
	self._txt.xScale = 1/Stage.scaleValue
	self._txt.yScale = 1/Stage.scaleValue

	if (self.align == 1) then
		self._txt.x = self._txt.width / 2 / Stage.scaleValue
		self._txt.y = self._txt.height / 2 / Stage.scaleValue
	elseif(self.align == 2) then
		self._txt.x = 0
		self._txt.y = self._txt.height / 2 / Stage.scaleValue
	elseif(self.align == 3) then
		self._txt.x = -self._txt.width / 2 / Stage.scaleValue
		self._txt.y = self._txt.height / 2 / Stage.scaleValue
	elseif(self.align == 4) then
		self._txt.x = -self._txt.width / 2 / Stage.scaleValue
		self._txt.y = 0
	elseif(self.align == 5) then
		self._txt.x = -self._txt.width / 2 / Stage.scaleValue
		self._txt.y = -self._txt.height / 2 / Stage.scaleValue
	elseif(self.align == 6) then
		self._txt.x = 0
		self._txt.y = -self._txt.height / 2 / Stage.scaleValue
	elseif(self.align == 7) then
		self._txt.x = self._txt.width / 2 / Stage.scaleValue
		self._txt.y = -self._txt.height / 2 / Stage.scaleValue
	elseif(self.align == 8) then
		self._txt.x = self._txt.width / 2 / Stage.scaleValue
		self._txt.y = 0
	else 
		self._txt.x = 0
		self._txt.y = 0
	end
	
end

function Label:set_text(value)
	self._text = value
	self:redraw()
end

function Label:set_align(value)
	self._align = value
	self:redraw()
end

function Label:set_size(value)
	self._size = value
	self:redraw()
end

function Label:set_font(value)
	self._font = value
	self:recreate()
end

function Label:set_color(value)
	self._color = value
	self:recreate()
end
