--- Marcos Bottenbley
--- mbotten1@jhu.edu

--- Rebecca Bushko
--- rbushko1@jhu.edu

--- Adam Ellenbogen
--- aellenb1@jhu.edu

--- David Miller
--- dmill118@jhu.edu

Object = require("Object")
math.randomseed(os.time())

local Missile = {
	vel = 350, turnSpeed = math.pi*(3/2),
	lockDistance, lockTime,
	id = 3, collided = false,
	width = 10, height = 10,
	bounding_rad = 12.5, angle = 0,
	target_x, target_y, target,
	hb_1
}
Missile.__index = Missile

setmetatable(Missile, {
	__index = Object,
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:_init(...)
		return self
	end,
})

--- initial spawn information

function Missile:_init(x, y, v, a)
	self.vel = v
	self.angle = a
	Object._init(self, x, y,
		self.img,
		self.width,
		self.height,
		self.frames,
		self.states,
		self.delay)

	self.hb_1 = {self.x, self.y, self.bounding_rad}-- + self.width/2, self.y + 5, self.bounding_rad}
end

--- Missile, hitbox speed and direction

function Missile:update(dt)
	local closestDist = 600
	self.target_x = nil
	self.target_y = nil
	for _, o in ipairs(objects) do
		if self:dist(o) < closestDist and o:getID() == 1 then
			self.target_x = o:getX()
			self.target_y = o:getY()
			self.target = o
			closestDist = self:dist(o)
		end
	end
	
	local target_angle = 0
	if self.target_x ~= nil and self.target_y ~= nil then
		if self.target_x - self.x > 0 then
			target_angle = math.atan(-(self.target_y - self.y) / (self.target_x - self.x))
			if target_angle < 0 then
				target_angle = target_angle + math.pi*2
			end
		else
			target_angle = math.atan(-(self.target_y - self.y) / (self.target_x - self.x)) + math.pi
		end
	else
		target_angle = self.angle
	end
	
	local rotate = self:angleDir(self.angle, target_angle)
	local angvel = rotate * self.turnSpeed * dt
	self.angle = self.angle + angvel
	
	self.y = self.y - (math.sin(self.angle)*self.vel*dt)
	self.x = self.x + (math.cos(self.angle)*self.vel*dt)
	
	self.hb_1 = {self.x, self.y, self.bounding_rad}
end

function Missile:draw()
	love.graphics.setColor(255,188,188,188)
	
	local vertices = {
	self.x - 12.5, self.y - 10.825,
	self.x + 12.5, self.y - 10.825,
	self.x, self.y + 10.825
	}
	
	love.graphics.polygon('fill', vertices)
	
	love.graphics.setColor(255,255,255,255)
end

--- handles when a Missile exits the map

function Missile:exited_map(width, height)
	local y_pos = self.y + self.height
	local x_pos = self.x + self.height
	if y_pos < 0 or x_pos < 0 or y_pos > height or x_pos > width then
		return true
	end
end

function Missile:dist(obj)
	return math.sqrt((obj:getX() - self.x)^2 + (obj:getY() - self.y)^2)
end

function Missile:angleDir(a_start, a_finish)
	local diff = a_start - a_finish
	
	if math.abs(diff) > math.pi then
		if diff > 0 then return 1
		else return -1
		end
	elseif math.abs(diff) < math.pi then
		if diff < 0 then return 1
		elseif diff > 0 then return -1
		else return 0
		end
	end
end

function Missile:getHitBoxes( ... )
	local hb = {}
	table.insert(hb, self.hb_1)
	return hb
end

return Missile
