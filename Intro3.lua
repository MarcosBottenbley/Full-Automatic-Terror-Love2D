--- Marcos Bottenbley
--- mbotten1@jhu.edu

--- Rebecca Bushko
--- rbushko1@jhu.edu

--- Adam Ellenbogen
--- aellenb1@jhu.edu

--- David Miller
--- dmill118@jhu.edu

State = require("State")

local time = 0
local changed = 0
local bgm

local Intro3 = {
	bg = nil, pos = 0,
	script_pos = 1,
	lines = {}
}
Intro3.__index = Intro3

setmetatable(Intro3, {
	__index = State,
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:_init(...)
		return self
	end,
})

function Intro3:load()
	self.list_font = love.graphics.newFont("PressStart2P.ttf", 17)
	text_height = (self.list_font):getHeight()
	self.bg = love.graphics.newImage("gfx/intro_screen.png")

	self.pos = -(self.bg:getHeight() - height)

	bgm = love.audio.newSource("sfx/cutscene.ogg")
	bgm:setLooping(true)
end

function Intro3:start()
	self.lines = {
		"After battling through \nwave after wave of ships,\n" ..
		"you are overwhelmed by \nenemy forces and captured",
		"I know you might have been \ndoing pretty well in the level\n" ..
		"but trust me \nit was pretty overwhelming",
		"They have taken you to \nSpace Jail, a treacherous\n" ..
		"labyrinth of lasers and wormholes",
		"Are you xtreme enough to break out?"
	}

	time = 0
	changed = 0
	self.pos = -(self.bg:getHeight() - height)
	self.script_pos = 1

	bgm:play()
end

function Intro3:update(dt)
	time = time + 1 * dt
	self.pos = self.pos + 50 * dt

	if self.pos >= 0 then
		self.pos = 0
	end

	if math.floor(time) % 5 == 0 and self.script_pos < table.getn(self.lines) then
		if changed ~= math.floor(time) then
			self.script_pos = self.script_pos + 1
		end
		changed = math.floor(time)
	end

	if time > table.getn(self.lines) * 5 then
		switchTo(Game)
	end
end

function Intro3:keyreleased(key)
	switchTo(Game)
end

function Intro3:keypressed(key)
end

function Intro3:stop()
	time = 0
	changed = 0
	self.pos = -(self.bg:getHeight() - height)
	self.script_pos = 1

	bgm:stop()
end

function Intro3:draw()
	love.graphics.setFont(self.list_font)
	love.graphics.translate(0,self.pos)
	love.graphics.setColor(255, 50, 255, 50)
	love.graphics.draw(self.bg, 0, 0)
	love.graphics.setColor(255, 255, 255, 255)

	if time >= 2 then
		love.graphics.translate(0, -self.pos)

		love.graphics.setColor(20, 20, 20, 160)
		love.graphics.rectangle("fill", 20, height/2 + text_height * 4 - 20, 680, 180)
		love.graphics.setColor(255, 255, 255, 255)
		-- border
		love.graphics.rectangle("line", 30, height/2 + text_height * 4 - 10, 660, 160)

		love.graphics.print(self.lines[self.script_pos], 45, height/2 + text_height * 4 + 5)
	end
end

return Intro3