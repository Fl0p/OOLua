local json = require("json")

require("config")

StageClass = class("StageClass",SuperObject)


StageClass:include(Branchy)
StageClass:include(Accessors)

--StageClass:access("hiddenGroup",nil,true)
StageClass:access("stageWidth",application.content.stageWidth,true)
StageClass:access("stageHeight",application.content.stageHeight,true)
StageClass:access("displayWidth",0,true)
StageClass:access("displayHeight",0,true)
StageClass:access("stageScaleMode",application.content.stageScaleMode,true)
StageClass:access("xScale",1,true)
StageClass:access("yScale",1,true)
StageClass:access("mScale",1,true) -- maximum scale (non uniform scaling) 

StageClass:access("scaleValue",1,true) -- nearest scale fom application.content.stageScales
StageClass:access("scaleSuffix","",true) -- nearest suffix fom application.content.stageScales


StageClass:access("xAlign",application.content.stageAlignX,true)
StageClass:access("yAlign",application.content.stageAlignY,true)

--StageClass:access("retina",false,true)


-- Singleton implementation

local __SE__ = {} -- singletonEnforcer

-- StageClass 
	
function StageClass:initialize(se)
	
	if(se == __SE__ and StageClass.StageClass == nil) then
		print("!! StageClass instance creation")
		
		self:super("initialize")
		
		self._displayWidth = display.contentWidth
		self._displayHeight = display.contentHeight
		
		local displayGroup = display.newGroup()
		
		self._StageClassDisplayList = displayGroup
		displayGroup:toBack()
		--self._StageClassDisplayList.alpha = 0.1

		self._StageClassHiddenGroup = display.newGroup()
		--self._StageClassHiddenGroup.alpha = 0.5
		self._StageClassHiddenGroup.isVisible = false
		self._StageClassHiddenGroup:toBack()

		-- background
		r = display.newRect(displayGroup,0,0,self.stageWidth,self.stageHeight)
		r.strokeWidth = 0
		r:setFillColor(application.content.stageColorR, application.content.stageColorG, application.content.stageColorB)
		
		-- scale stage
		if (self.stageScaleMode == "letterbox") then

			local s_w = self.displayWidth / self.stageWidth 
			local s_h = self.displayHeight / self.stageHeight 
			if (s_w > s_h) then
				self._xScale = s_h
				self._yScale = s_h
			else
				self._xScale = s_w
				self._yScale = s_w
			end
		end
		
		

		displayGroup.xScale = self.xScale;
		displayGroup.yScale = self.yScale;
		
		
		if (self.xScale > self.yScale) then
			self._mScale = self.xScale
		else
			self._mScale = self.yScale
		end
		
		--pure perfomance with stage rotation
		--need to create different orientation in scale modes
		--only portriat mode supported for now
		--displayGroup.rotation = 90
		--displayGroup_add_x = self.displayWidth
		--displayGroup_add_y = 0--self.stageWidth
		
		--align stage x
		if(self.xAlign == "center") then
			displayGroup.x = math.floor((self.displayWidth - self.stageWidth * self.xScale)/2 + 0.5)
		end
			
		
		--slign stage y
		if(self.yAlign == "center") then
			displayGroup.y = math.floor((self.displayHeight - self.stageHeight * self.yScale)/2 + 0.5)
		end

		--scale suffixes parce
		local t = application.content.stageScales
		
		for k,v in pairs(t) do
			--print("---",k,v)
			if ( self.mScale >= v and self.scaleValue < v) then
				self._scaleValue = v
				self._scaleSuffix = k
			end
			
		end
		
		if (application.content.stageLog) then
			self:enableLog()
			self:doLog("Logging enabled")
		end

		if (application.content.stageMW) then
			self:enableMW()
		end		
		
		--print("SCALE",self.mScale,self.scaleValue,self.scaleSuffix)
		
	else
		error("Only ONE instance of a StageClass can be created, use StageClass.StageClass")
	end

end

	--loging
function StageClass:enableLog()
	
	self._StageClassLogGroup = display.newGroup()
	
	local r = display.newRect(self._StageClassLogGroup , 0,0,480,320)
	r.alpha = 0.7

	local d = self._StageClassDisplayList.y+28*self.mScale
	--print("!!!!!!!!!!!!!",d)
	local logText = native.newTextBox( 0, d, self.displayWidth , self.displayHeight-d  )
	--display.newRect(0, d, self.displayWidth , self.displayHeight-d)
	logText.hasBackground = false
	self._StageClassLogText = logText
	logText.text = "  --- Log --- "

	local k = display.newCircle(self._StageClassLogGroup, 240,0,28)

	local function logSwitch(event)
		if (event.phase ~= "ended") then return end

		if (r.isVisible) then
			r.isVisible = false
			logText.isVisible = false
		else
			r.isVisible = true
			logText.isVisible = true
		end
		
		return true
	end
	
	k:addEventListener("touch",logSwitch)

	logSwitch({phase="ended"})

	self._StageClassLogGroup.x = self._StageClassDisplayList.x
	self._StageClassLogGroup.y = self._StageClassDisplayList.y
	self._StageClassLogGroup.xScale = self._StageClassDisplayList.xScale
	self._StageClassLogGroup.yScale = self._StageClassDisplayList.yScale
	
end

function StageClass:doLog(...)
	

	local f = os.date( "%X" )
	
	local msg = ""
	for i = 1,select("#",...),1 do
		local o = select(i,...)
		--if (type(o) == "table") then
		--	msg = msg .. "table ->" .. json.encode(o) 
		--else
			msg = msg  .. tostring(o) 
		--end
		if (i ~= select("#",...)) then 
			msg = msg .. "\n\t" 
		end
	end
	print("### " .. f .. " # " .. msg)
	if (self._StageClassLogGroup == nil) then return end
	self._StageClassLogText.text = 	self._StageClassLogText.text .. "\n" .. f .. " # " .. msg
end
function StageClass:logClear()
	self._StageClassLogText.text = ""
end

function StageClass:logMem()
	
	self:doLog("MEMORY",
	"System : " .. tostring(collectgarbage( "count" ) ) ,
	"Texture : " .. system.getInfo( "textureMemoryUsed" ) )
	return m
end


function StageClass:enableMW()
	
	local function handleLowMemory( event )
		self:doLog("Memory warning received !")
		local m = self:logMem()
		if (event) then
			for k,v in pairs(event) do
				m = m .. "\n\t--- " .. k .. " = " .. tostring(v)
			end
		end	
		self:gc()
		native.showAlert( "Memory warning received !", m, { "OK" } )
	end

	Runtime:addEventListener( "memoryWarning", handleLowMemory )
	--handleLowMemory()
end

function StageClass:gc()
	collectgarbage("restart")
	collectgarbage("collect")
end
 

function StageClass:screenShot()
	local s = Sprite()
	--[[
	local cap = display.captureScreen()
	cap.xScale = 1/Stage.mScale
	cap.yScale = 1/Stage.mScale
	cap.x = 240
	cap.y = 160
	s.displayObject:insert(cap)
	--]]
	return s
end

--[[
function StageClass:get_hiddenGroup()
	return self._StageClassHiddenGroup;
end
--]]



function StageClass:spriteToHidden(sprite)
	assert(instanceOf(Sprite,sprite) , tostring(sprite) .. " is not instance of Sprite class")
	--Branchy.addChild(self,sprite)
	if(sprite.parent) then 
		print("REMOVE PARENT",sprite.parent)
		--sprite.parent:removeChild(sprite)
		--sprite.parent = nil
		--sprite.root = nil
	end	
	
	self._StageClassHiddenGroup:insert(sprite._displayObject)
end


function StageClass:addChild(sprite)
	assert(instanceOf(Sprite,sprite) , tostring(sprite) .. " is not instance of Sprite class")
	Branchy.addChild(self,sprite)
	self._StageClassDisplayList:insert(sprite._displayObject)
end

function StageClass:removeChild(sprite)
	assert(instanceOf(Sprite,sprite) , tostring(sprite) .. " is not instance of Sprite class")
	self._StageClassHiddenGroup:insert(sprite._displayObject)
	Branchy.removeChild(self,sprite)
end

-- Stage Instancing
Stage = {}

local stageInstance = StageClass(__SE__)

print()
print("Stage: ", stageInstance)

local mt = {}

mt.__index = function(t,k) 
	return stageInstance[k]
end

mt.__newindex = function(t,k,v)
	error("Stage can't be changed")
end

setmetatable(Stage,mt)
