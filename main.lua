class = require 'ext.middleclass'

Tilemap = require 'tilemap'

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    tm = Tilemap(require 'map_001')
    love.window.setMode(tm.image_width * tm.tileset.cell_width, tm.image_height * tm.tileset.cell_height)
end

function love.update(dt)

end

function love.draw()
    love.graphics.setColor(1,1,1,1)
    tm:draw(0, 0)

    love.graphics.setColor(0,1,0,0.25)
    for _, b in pairs(tm.boxes) do
        love.graphics.rectangle('line', b.x, b.y, b.w, b.h)
    end
end

