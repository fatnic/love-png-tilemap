map = {
    filename = "test_001.png",

    tileset = {
        filename = "tileset.png",
        h_frames = 4,
        v_frames = 4
    },

    colours = {
        ["0,0,0,0"]       = 0,
        ["0,0,0,255"]     = 1,
        ["255,0,0,255"]   = 2,
        ["255,255,0,255"] = 3,
        ["0,255,0,255"]   = 4,
        ["0,0,255,255"]   = 5
    },

    autotile = true,

    collision = true

}

return map
