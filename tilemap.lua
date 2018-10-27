Tilemap = class('Tilemap')


function Tilemap:initialize(config)
    self.image_data = love.image.newImageData(config.filename)
    self.image_width, self.image_height = self.image_data:getDimensions()
    self.color_data = config.colours
    self.tileset = {}

    self:setTileset(config.tileset.filename, config.tileset.h_frames, config.tileset.v_frames)

    self.cell_data = self:generateColourMap()
    if config.autotile then self:autotile() end

    self:generateStatic()

    self.boxes = {}
    if config.collision then self:boxGen() end
end

function Tilemap:generateColourMap()

    local cells = {}

    for y = 1, self.image_height do
        row = {}
        for x = 1, self.image_width do
            r, g, b, a = self.image_data:getPixel(x - 1, y - 1)
            local c_string = string.format("%d,%d,%d,%d", r * 255, g * 255, b * 255, a * 255)
            local cell_data = self.color_data[c_string] and self.color_data[c_string] or -1
            table.insert(row, cell_data) 
        end
        table.insert(cells, row)
    end

    return cells

end

function Tilemap:setTileset(filename, h_frames, v_frames)
    self.tileset.image = love.graphics.newImage(filename)
    self.tileset.image_width = self.tileset.image:getWidth()
    self.tileset.image_height = self.tileset.image:getHeight()
    self.tileset.h_frames = h_frames
    self.tileset.v_frames = v_frames
    self.tileset.cell_width  = self.tileset.image_width  / self.tileset.h_frames
    self.tileset.cell_height = self.tileset.image_height / self.tileset.v_frames

    self.tileset.quad = love.graphics.newQuad(0, 0, self.tileset.cell_width, self.tileset.cell_height, self.tileset.image_width, self.tileset.image_height)
    x,y,w,h = self.tileset.quad:getViewport()
end

function Tilemap:generateStatic()

    local static_canvas = love.graphics.newCanvas(self.image_width * self.tileset.cell_width, self.image_height * self.tileset.cell_height)
    love.graphics.setCanvas(static_canvas) 

    for y = 1, #self.cell_data do
        for x = 1, #self.cell_data[1] do

            if self.cell_data[y][x] > 0 then

                cell_x, cell_y = self:tilesetXY(self.cell_data[y][x])
                self.tileset.quad:setViewport(cell_x, cell_y, self.tileset.cell_width, self.tileset.cell_height)

                local tilemap_x = (x - 1) * self.tileset.cell_width
                local tilemap_y = (y - 1) * self.tileset.cell_height

                love.graphics.draw(self.tileset.image, self.tileset.quad, tilemap_x, tilemap_y)               

            end
        end
    end
    love.graphics.setCanvas() 

    self.tilemap_image = love.graphics.newImage(static_canvas:newImageData()) 
end

function Tilemap:tilesetXY(tile_number)
        local cell_x = ((tile_number - 1) % self.tileset.h_frames) * self.tileset.cell_width
        local cell_y = math.floor((tile_number - 1) / self.tileset.h_frames) * self.tileset.cell_height
        return cell_x, cell_y
end

function Tilemap:autotile()

    for y = 1, #self.cell_data do
        for x = 1, #self.cell_data[1] do
            if self.cell_data[y][x] > 0 then
                self.cell_data[y][x] = self:calcTile(x, y) 
            end
        end
    end

end

local walls = { ["0,-1"] = 1, ["1,0"] = 2, ["0,1"] = 4, ["-1,0"] = 8 }

function Tilemap:calcTile(x, y)
    local tile = 0

    for k, v in pairs(walls) do

        local vx, vy = string.match(k, "([-]?%d),([-]?%d)")

        local current_x = x + vx
        local current_y = y + vy

        if current_x < 1 or current_x > self.image_width or current_y < 1 or current_y > self.image_height then
            tile = tile + walls[k]
        else
            neighbour = self.cell_data[current_y][current_x]
            if neighbour > 0 then tile = tile + walls[k] end
        end

    end
    return tile + 1
end

function Tilemap:boxGen()

    bs = nil
    cell_w = self.tileset.cell_width
    cell_h = self.tileset.cell_height

    function add_box(bs, be)
        table.insert(self.boxes, { x = (bs.x - 1) * cell_w, y = (bs.y - 1) * cell_h, w = cell_w, h = cell_h })
        bs = nil
    end

    for y = 1, #self.cell_data do
        for x = 1, #self.cell_data[1] do
            
             if self.cell_data[y][x] > 0 then
                 add_box( { x = x, y = y }, { x = 1, y = 1 } )
             end
            
        end

    end


end

function Tilemap:draw(x, y, sx, sy)
    local x = x or 0
    local y = y or 0
    local sx = sx or 1
    local sy = sy or 1
    love.graphics.draw(self.tilemap_image, x, y, 0, sx, sy)
end

return Tilemap
