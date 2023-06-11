local BASE_WIDTH = 500
local BASE_HEIGHT = 500

---@class Pole
---@field shader love.Shader
---@field canvas love.Canvas
---@field topleft table

---@class Game
---@field width number
---@field height number
---@field backgroundCanvas love.Canvas
---@field pole Pole
local Game = {}

---@type Game
local towerJumper

function Game:new(baseWidth, baseHeight)
	---@type Game
	local game = {
		width = baseWidth,
		height = baseHeight
	}
	setmetatable(game, self)
	self.__index = self

	-- init background

	local canvas = love.graphics.newCanvas(baseWidth, baseHeight)
	game.backgroundCanvas = canvas

	love.graphics.setCanvas(canvas)
	local oldColor = {love.graphics.getColor()}
	love.graphics.setColor(0.5, 0.8, 0.8)

	love.graphics.rectangle('fill', 0, 0, baseWidth, baseHeight)

	love.graphics.setColor(unpack(oldColor))
	love.graphics.setCanvas()

	-- init pole

	---@type Pole
	local pole = {
		shader = love.graphics.newShader[[
			vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
				texture_coords = vec2(texture_coords.x, 1. - texture_coords.y);
				vec2 uv = texture_coords * 2. - 1.;
				vec3 normal = vec3(uv.x, 0., sqrt(1. - uv.x * uv.x));
				vec3 pos = vec3(uv, normal.z);

				vec3 sun = vec3(2., 1., 2.);

				vec3 delta_pos = sun - pos;
				float cosine = dot(normal, normalize(delta_pos));
				float intensity = (cosine + 1.)/2.;

				return vec4(vec3(intensity), 1.);
			}
		]],
		canvas = love.graphics.newCanvas(baseWidth*0.2, baseHeight),
	}
	pole.topleft = {game.width*0.5-pole.canvas:getWidth()*0.5, 0}
	game.pole = pole

	love.graphics.setCanvas(pole.canvas)
	oldColor = {love.graphics.getColor()}
	love.graphics.setColor(1, 1, 1)

	love.graphics.rectangle('fill', 0, 0, pole.canvas:getWidth(), pole.canvas:getHeight())

	love.graphics.setColor(unpack(oldColor))
	love.graphics.setCanvas()

	return game
end

function Game:draw()
	-- draw background

	love.graphics.draw(self.backgroundCanvas, 0, 0)

	-- draw pole

	local pole = self.pole

	love.graphics.setShader(pole.shader)
	love.graphics.draw(pole.canvas, unpack(towerJumper.pole.topleft))
	love.graphics.setShader()
end

function love.load()
	local success = love.window.setMode(BASE_WIDTH, BASE_HEIGHT, {resizable=false})
	towerJumper = Game:new(BASE_WIDTH, BASE_HEIGHT)
end

function love.draw()
	towerJumper:draw()
end
