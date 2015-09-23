State = require("State")

local Game = {}
local help = "Press H for high scores and Esc for menu"
Game.__index = Game

setmetatable(Game, {
	__index = State,
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:_init(...)
		return self
	end,
})

function Game:load(arg)
	math.randomseed(os.time())

	Player = require("Player")
	GlowBorg = require("GlowBorg")
	Bullet = require("Bullet")
	
	enemy_sprite = love.graphics.newImage("gfx/gel.png")
	enemy_width = enemy_sprite:getWidth()
	enemy_height = enemy_sprite:getHeight()
	
	player_sprite = love.graphics.newImage("gfx/toast.png")
	player_width = player_sprite:getWidth()
	player_height = player_sprite:getHeight()
	
	self.helpfont = love.graphics.newFont("PressStart2P.ttf", 12)
	
	blip = love.audio.newSource("sfx/bump.ogg")
	blip:setLooping(false)
	
	bgm = love.audio.newSource("sfx/gamelow.ogg")
	bgm:setLooping(true)

	background = love.graphics.newImage("gfx/game_screen.png")

	enemies = {}
	bullets = {}

	for i = 1, 9 do
		--table.insert(enemies, Enemy(math.random(800 - enemy_width), math.random(600 - enemy_height), math.random(40,80)))
		table.insert(enemies, GlowBorg())
	end

	for _, e in ipairs(enemies) do
		e:direction()
	end

	player1 = Player(width/2, height/2, 200)
	
end

function Game:start()
	bgm:play()
end

function Game:stop()
	bgm:stop()
	
end

function Game:update(dt)
	time = time + dt

	for _, e in ipairs(enemies) do
		e:update(dt, width, height)
	end
	
	for _, e in ipairs(bullets) do
		e:update(dt, width, height)
	end

	player1:update(dt, width, height)

end

function Game:draw(dt)
	love.graphics.draw(background, 0, 0)
	love.graphics.setFont(self.helpfont)

	love.graphics.print(
		help,
		10, height - 10
	)
	
	for _, e in ipairs(bullets) do
		e:draw()
	end

	player1:draw()
	
	for _, e in ipairs(enemies) do
		e:draw()
	end
end

function Game:keyreleased(key)
	player1:keyreleased(key)
	
	if key == 'escape' then
		switchTo(Menu)
	end
	
	if key == 'h' then
		switchTo(ScoreScreen)
	end
end

return Game