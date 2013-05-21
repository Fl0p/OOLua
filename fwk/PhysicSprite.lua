local physics = require("physics")


PhysicSprite = class("PhysicSprite",Sprite)


PhysicSprite:access("isBullet",false)
PhysicSprite:access("physicBody",nil,true)
PhysicSprite:access("physicalSprite",nil,true)
PhysicSprite:access("isBodyActive",true)
PhysicSprite:access("isFixedRotation",false)
PhysicSprite:access("linearDamping",0.6)
PhysicSprite:access("angularDamping",1)
PhysicSprite:access("angularVelocity",0)


function PhysicSprite:initialize(type,body,filters)
 	self:super("initialize",radius)

	if (type == nil) then type = "dynamic" end
	if (body == nil) then body = {} end
	if (body.shape == nil and body.radius == nil) then body.radius = 10 end
	if (body.density == nil) then body.density = 0.5  end
	if (body.friction == nil) then body.friction = 0.2  end
	if (body.bounce == nil) then body.bounce = 0.5  end
	if (filters == nil) then body.filters = { categoryBits = 1, maskBits = 255 }  end

	self._physicalSprite = true
	self._physicBody = body
	
	physics.addBody(self.displayObject, type, self._physicBody )
	
end

function PhysicSprite:rotateSpeedVector(angle)
	angle = 3.1415*angle/180
	local vx,vy = self.displayObject:getLinearVelocity()
	local _vx_ = vx*math.cos(angle) - vy*math.sin(angle)
	local _vy_ = vx*math.sin(angle) + vy*math.cos(angle)	
	
	self.displayObject:setLinearVelocity( _vx_, _vy_ )
	
end
	
function PhysicSprite:removeSelf()
	--print("REMOVE PHYSICS BODY" , self)
	self:setLinearVelocity(0, 0)
	self.angularVelocity = 0
	self.isBodyActive = false
	self:super("removeSelf")
end

function PhysicSprite:destroy()
	self:setLinearVelocity(0, 0)
	self.angularVelocity = 0
	self.isBodyActive = false
	-- hope object go out of the AABB physic box
	self.x = 999999999
	self.y = 999999999
	
	--[[ add this in next corona build
	if not physics.removeBody( object ) then
	    print( "Could not remove Physics body" )
	end	
	--]]
	self:super("destroy")
end

function PhysicSprite:set_isBullet(value)
	self.displayObject.isBullet = value
end
function PhysicSprite:get_isBullet()
	return self.displayObject.isBullet
end

function PhysicSprite:set_isBodyActive(value)
	self.displayObject.isBodyActive = value
end
function PhysicSprite:get_isBodyActive()
	return self.displayObject.isBodyActive
end

function PhysicSprite:set_isFixedRotation(value)
	self.displayObject.isFixedRotation = value
end
function PhysicSprite:get_isFixedRotation()
	return self.displayObject.isFixedRotation
end

function PhysicSprite:set_linearDamping(value)
	self.displayObject.linearDamping = value
end
function PhysicSprite:get_linearDamping()
	return self.displayObject.linearDamping
end

function PhysicSprite:set_angularDamping(value)
	self.displayObject.angularDamping = value
end
function PhysicSprite:get_angularDamping()
	return self.displayObject.angularDamping
end

function PhysicSprite:get_angularVelocity()
	return self.displayObject.angularVelocity
end

function PhysicSprite:set_angularVelocity(value)
	self.displayObject.angularVelocity = value
end

function PhysicSprite:getLinearVelocity()
	return self.displayObject:getLinearVelocity()
end

function PhysicSprite:setLinearVelocity(vx,vy)
	self.displayObject:setLinearVelocity(vx,vy)
end

function PhysicSprite:applyForce(fx,fy)
	self.displayObject:applyForce(fx,fy)
end