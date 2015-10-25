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
local f_timer = 0
local firable = false

local timeChange

local Player = {
	vel = 0, max_vel = 200,
	accel = 0, max_accel = 800,
	img = "gfx/main_ship_sheet.png",
	width = 42, height = 57,
	frames = 5, states = 2,
	delay = 0.12, sprites = {},
	id = 2, collided = false,
	bounding_rad = 25, angle1 = math.pi/2,
	ang_vel = 0, double = false,
	health = 10, bomb = 3, h_jump = 2,
	invul = false, d_timer = 0, damaged = false,
	i_timer = 0, missile = false,
	bomb_flash = false, flash_timer = .6,
	teleporttimer = 0, bulletSpeed = .18,
	inframe = false, jumptimer = 0, isjumping = false,
	camera_x = 0, camera_y = 0
}
Player.__index = Player

setmetatable(Player, {
	__index = Object,
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:_init(...)
		return self
	end,
})

function Player:_init(x, y, v)
	Object._init(self, x, y,
		self.img,
		self.width,
		self.height,
		self.frames,
		self.states,
		self.delay)

	self.max_vel = v

	self.hb_1 = {self.x, self.y - 18.5, 10}
	self.hb_2 = {self.x, self.y + 10.5, 19}

	self.validCollisions = {1,6,5,7,8}
end

function Player:load()
	Object.load(self)
	pew = love.audio.newSource("sfx/pew.ogg")
	pew:setLooping(false)
	playerhit = love.audio.newSource("sfx/playerhit.ogg")
	playerhit:setLooping(false)
end

function Player:update(dt, swidth, sheight)
	Object.update(self,dt)
	f_timer = f_timer + dt
	timeChange = dt

	if f_timer >= self.bulletSpeed then
		firable = true
	else
	    firable = false
	end

	if isjumping == true then
		jumptimer = jumptimer + dt
		self.vel = 1000
		self.invul = true
		if jumptimer > 1 then
			self.invul = false
			self.vel = 200
			isjumping = false
			jumptimer = 0
		end
	end

	self.teleporttimer = self.teleporttimer + dt

	if self.flash_timer > .58 then
		self.bomb_flash = false
	end

	if self.damaged then
		self.d_timer = self.d_timer + dt
	end

	if self.d_timer > 0.5 then
		self.damaged = false
		self.d_timer = 0
	end

	if self.health < 1 then
		self.collided = true
	end

	if self.invul then
		self.i_timer = self.i_timer + dt
	end

	if self.i_timer > .25 then
		self.i_timer = 0
	end

	--turn left or right
	if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
		if love.keyboard.isDown('x') then
			self.y = self.y - math.sin(self.angle1 + math.pi/2)*self.max_vel*dt
			self.x = self.x + math.cos(self.angle1 + math.pi/2)*self.max_vel*dt
		else
			self:turn(1)
		end
	elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
		if love.keyboard.isDown('x') then
			self.y = self.y - math.sin(self.angle1 - math.pi/2)*self.max_vel*dt
			self.x = self.x + math.cos(self.angle1 - math.pi/2)*self.max_vel*dt
		else
			self:turn(-1)
		end
	end
	self.angle1 = self.angle1 + self.ang_vel * dt

	--is the player moving
	local moving = false

	--get acceleration (if not moving, accelerate opposite velocity)
	if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
	 	self.accel = -self.max_accel
		moving = true
	elseif love.keyboard.isDown('up') or love.keyboard.isDown('w') then
		self.accel = self.max_accel
		moving = true
	elseif self.vel > 0 then
		self.accel = -self.max_accel
	elseif self.vel < 0 then
		self.accel = self.max_accel
	else
		self.accel = 0
	end

	--accelerate (not past max velocity)
	if (self.accel >= 0 and self.vel < self.max_vel) or
		(self.accel <= 0 and self.vel > -self.max_vel) then
		self.vel = self.vel + self.accel * dt
	end

	print(self.vel)

	--stop player from moving back and forth when not pressing up/down
	if math.abs(self.vel) < self.max_vel / 10 and not moving then
		self.vel = 0
	end

	self.y = self.y - math.sin(self.angle1)*self.vel*dt
	self.x = self.x + math.cos(self.angle1)*self.vel*dt

	if self.x < 1 then
		self.x = 1
	end

	if self.y < 1 then
		self.y = 1
	end

	if self.x > (swidth - self.width) then
		self.x = (swidth - self.width)
	end

	if self.y > (sheight - self.height) then
		self.y = (sheight - self.height)
	end

	self.hb_1[1] = self.x + 18.5 * math.cos(self.angle1)
	self.hb_1[2] = self.y - 18.5 * math.sin(self.angle1)

	self.hb_2[1] = self.x - 10.5 * math.cos(self.angle1)
	self.hb_2[2] = self.y + 10.5 * math.sin(self.angle1)

	self.flash_timer = self.flash_timer + dt

	if love.keyboard.isDown('z') then
		if firable then
			self:fire()
		end
	end
end

function Player:draw()
	local draw_angle = math.pi/2 - self.angle1
	if self.damaged then
		Object.draw(self,155,155,155, draw_angle)
	else
		if self.i_timer > 0.125 then
			Object.draw(self,255,255,0, draw_angle)
		else
			Object.draw(self,255,255,255, draw_angle)
		end
	end
end

function Player:keyreleased(key)
	if key == 'left' or key == 'right' or key == 'a' or key == 'd' then
		self.ang_vel = 0
	end

	if key == 'i' then
		self:toggleInvul()
	end

	if key == 'b' then
		self:useBomb()
	end
	
	if key == 'h' then
		self:useJump()
	end
	
	if key == '1' then
		self:weaponSelect()
	end
end

--Changes the player's angle based on the direction passed in.
--Passing in 1 increases the angle (turns left) and -1 decreases
--the angle (turns right).
function Player:turn(direction)
	if direction == 1 or direction == -1 then
		self.ang_vel = math.pi * direction
	end
end

function Player:fire()
	f_timer = 0
	pew:play()
	if self.missile then
		local m = Missile(self.hb_1[1], self.hb_1[2], 600, self.angle1)
		table.insert(objects, m)
	elseif self.double then
		--code
		local b1 = Bullet(self.hb_1[1] + 10*math.sin(self.angle1), self.hb_1[2] + 10*math.cos(self.angle1), 600, self.angle1) --magic numbers errywhere
		local b2 = Bullet(self.hb_1[1] - 10*math.sin(self.angle1), self.hb_1[2] - 10*math.cos(self.angle1), 600, self.angle1) --magic numbers errywhere
		table.insert(objects, b1)
		table.insert(objects, b2)
	else
		local b = Bullet(self.hb_1[1], self.hb_1[2], 600, self.angle1) --magic numbers errywhere
		table.insert(objects, b)
	end
end

function Player:weaponSelect()
	self.missile = not self.missile
end

function Player:useJump()
	if self.h_jump == 0 then
		error:play()
	else
		jump:play()
		self.h_jump = self.h_jump - 1
		self.isJumping = true
	end
end

function Player:useBomb()
	if self.bomb == 0 then
		error:play()
	else
		self.bomb = self.bomb - 1
		bombblast:play()

		local length = table.getn(objects)
		-- loop through objects and remove enemies close to player
		for i = 0, length - 1 do
			local o = objects[length - i]
		  if (o:getX() > self.x - width/2 or o:getX() < self.x + width/2) and
			(o:getY() > self.y - height/2 or o:getY() < self.y + height/2) and
			(o:getID() == 1) then
				if o:getType() ~= 'b' then
				o:setDead()
				end
			end
			self.bomb_flash = true
			self.flash_timer = 0
		end
	end
end

function Player:toggleInvul()
	self.invul = not self.invul
	self.i_timer = 0
end

function Player:getHitBoxes( ... )
	local hb = {}
	table.insert(hb, self.hb_1)
	table.insert(hb, self.hb_2)

	return hb
end

function Player:explode()
	if self.exploded == false and self.current_state == 2 then
		--TODO: make uncollidable somehow?
		self.exploded = true
	end
end

function Player:setHitBoxes(x1, y1, x2, y2)
	self.hb_1[1] = x1
	self.hb_1[2] = y1

	self.hb_2[1] = x2
	self.hb_2[2] = y2
end

function Player:getX()
	return self.x
end

function Player:getY()
	return self.y
end

function Player:setX(newX)
	self.x = newX
end

function Player:setY(newY)
	self.y = newY
end

function Player:getWidth()
	return self.width
end

function Player:getHeight()
	return self.height
end

function Player:hit()
	if not (self.invul or self.damaged) then
		self.health = self.health - 1
		if self:alive() then
			self.damaged = true
			self.d_timer = 0
		end
		playerhit:play()
	end
end

function Player:alive()
	return self.health > 0
end

function Player:getHealth()
	return self.health
end

function Player:getBomb()
	return self.bomb
end

function Player:getJump()
	return self.h_jump
end

function Player:flash()
	return self.bomb_flash
end

function Player:getFlashTimer()
	return self.flash_timer
end

function Player:collide(obj)
	-- enemy
	if (obj:getID() == 1 and obj:getType() ~= 'b') or obj:getID() == 6 then
		self:hit()
		if not self:alive() then
			self.dead = true
		end
	-- powerup
	elseif obj:getID() == 5 then
		if obj:getType() == 'ds' then
			self.double = true
		elseif obj:getType() == 'r' then
			self.health = self.health + 2
		elseif obj:getType() == 'sp' then
			self.max_vel = self.max_vel + 100
		end
	-- wormhole
	elseif obj:getID() == 7 then
		if self.teleporttimer > 1 then
			self.teleporttimer = 0
			self.x, self.y = obj:teleport()
			teleport:play()
		end
		-- love.timer.sleep(0.2)
	elseif obj:getID() == 8 then
		self.y = self.y - math.sin(self.angle1)*-self.vel * timeChange
		self.x = self.x + math.cos(self.angle1)*-self.vel * timeChange

		self.vel = 0
	end
end

function Player:isDamaged()
	return self.damaged
end

function Player:enterFrame(x,y)
	self.camera_x, self.camera_y = -x, -y
	inframe = true
end

function Player:isInFrame()
	return inframe
end

function Player:getFrameCoordinates()
	return self.camera_x, self.camera_y
end

return Player
