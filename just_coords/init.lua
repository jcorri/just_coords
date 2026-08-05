
--     =================================
--    |                                 |
--    |      just_coords by jcorri      |
--    |                                 |
--    |          License:  MIT          |
--    |                                 | 
--     =================================

-- ===========================================
-- For activating the translate function "S()"
-- ===========================================

local S = minetest.get_translator("just_coords")

-- ======================================================
-- For determining the direction the player is looking at
-- ======================================================

local function get_cardinal_direction(yaw)
    if yaw < math.pi / 4 or yaw >= 7 * math.pi / 4 then
        return S("North")
    elseif yaw < 3 * math.pi / 4 then
        return S("West")
    elseif yaw < 5 * math.pi / 4 then
        return S("South")
    else
        return S("East")
    end
end

-- =====================================================
-- A table for getting the decimal color code of a Color
-- =====================================================
 
local color_map = {
    Cyan    = 65535,    -- (0x00FFFF)
    Magenta = 16711935, -- (0xFF00FF)
    Red     = 16711680, -- (0xFF0000)
    White   = 16777215, -- (0xFFFFFF)
    Yellow  = 16776960, -- (0xFFFF00)
}

-- =====================================================================
-- A table for getting the magnification factor of the current font size
-- =====================================================================
 
local size_map = {
    Normal = {x = 1,},     -- x100%   
    Big = {x = 1.25,},     -- x125%      
    Biggest = {x = 1.5,},  -- x150%
}

-- =========================================================================
-- A table for getting the vertical display position (y) in the display area
-- =========================================================================
 
local position_map = {
    Top = {x = 0.02, y = 0.2,},      
    Middle = {x = 0.02, y = 0.5,},
    Bottom = {x = 0.02, y = 0.8,},
}

-- ========================================
-- For creating the table containeing
-- the huds informations of all the players
-- ========================================

local hud_ids = {}

-- ====================================================
-- For setting the huds informations of each new player
-- ====================================================

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    hud_ids[name] = {
        -- "Position-Direction-Biome" is the mode to be used
        -- if the Initial Mode is set to "default" in the Mod settings
        mode = minetest.settings:get("coords_initial_mode") or "Position-Direction-Biome",
        outline_top = player:hud_add({
            type = "text",
            position = position_map[minetest.settings:get("coords_initial_position") or "Bottom"],
            offset = {x = 0, y = -1},
            size = size_map[minetest.settings:get("coords_initial_size") or "Normal"],
            text = S("Loading..."),
            alignment = {x = 1, y = 1},
            number = 0,                         -- Black
        }),
        outline_bottom = player:hud_add({
            type = "text",
            position = position_map[minetest.settings:get("coords_initial_position") or "Bottom"],
            offset = {x = 0, y = 1},
            size = size_map[minetest.settings:get("coords_initial_size") or "Normal"],
            text = S("Loading..."),
            alignment = {x = 1, y = 1},
            number = 0,                         -- Black
        }),
        outline_left = player:hud_add({
            type = "text",
            position = position_map[minetest.settings:get("coords_initial_position") or "Bottom"],
            offset = {x = -1, y = 0},
            size = size_map[minetest.settings:get("coords_initial_size") or "Normal"],
            text = S("Loading..."),
            alignment = {x = 1, y = 1},
            number = 0,                         -- Black
        }),
        outline_right = player:hud_add({
            type = "text",
            position = position_map[minetest.settings:get("coords_initial_position") or "Bottom"],
            offset = {x = 1, y = 0},
            size = size_map[minetest.settings:get("coords_initial_size") or "Normal"],
            text = S("Loading..."),
            alignment = {x = 1, y = 1},
            number = 0,                         -- Black
        }),
        fg = player:hud_add({
            type = "text",
            -- "Bottom" is the position to be used
            -- if the Initial position is set to "default" in the Mod settings
            position = position_map[minetest.settings:get("coords_initial_position") or "Bottom"],
            offset = {x = 0, y = 0},
            -- "Normal" is the size to be used
            -- if the Initial size is set to "default" in the Mod settings
            size = size_map[minetest.settings:get("coords_initial_size") or "Normal"],
            text = S("Loading..."),
            alignment = {x = 1, y = 1},
            -- "White" is the color to be used
            -- if the Initial color is set to "default" in the Mod settings
            number = color_map[minetest.settings:get("coords_initial_color") or "White"],
        }),
    }
end)

-- ===============================================================
-- For updating the huds informations of every player at each tick
-- ===============================================================

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local info = hud_ids[name]
        if info then
            local pos = player:get_pos()
            local yaw = player:get_look_horizontal()
            local dir = get_cardinal_direction(yaw)
            local biome_data = minetest.get_biome_data(pos)
            local biome_name = minetest.get_biome_name(biome_data.biome)
            local text
            if info.mode == "Coordinates-hidden" then text = ""
            elseif info.mode == "Position-only" then text = string.format("%.1f, %.1f, %.1f",
                pos.x, pos.y, pos.z)
            elseif info.mode == "Position-Direction" then text = string.format("%.1f, %.1f, %.1f\n--> %s",
                pos.x, pos.y, pos.z, dir)
            else text = string.format("%.1f, %.1f, %.1f\n--> %s\n%s",
                pos.x, pos.y, pos.z, dir, biome_name)
            end
            player:hud_change(info.outline_top, "text", text)
            player:hud_change(info.outline_bottom, "text", text)
            player:hud_change(info.outline_left, "text", text)
            player:hud_change(info.outline_right, "text", text)
            player:hud_change(info.fg, "text", text)
        end
    end
end)

-- ===========================================
-- Command for displaying the Help on the chat
-- ===========================================

minetest.register_chatcommand("coords", {
    description = "Show the list of the just_coords commands",
    func = function(name)
        return true,
        table.concat({
            S("List of the just_coords commands:"),
            S("/coords  → Show this list"),
            S("/coords-mode1 → Hide coordinates"),
            S("/coords-mode2 → Show Position only"),
            S("/coords-mode3 → Show Position + Direction"),
            S("/coords-mode4 → Show Position + Direction + Biome"),
            S("/coords-cyan → Set color to Cyan"),
            S("/coords-magenta → Set color to Magenta"),
            S("/coords-red → Set color to Red"),
            S("/coords-white → Set color to White"),
            S("/coords-yellow → Set color to Yellow"),
            S("/coords-normal → Set font size to Normal"),
            S("/coords-big → Set font size to Big"),
            S("/coords-biggest → Set font size to Biggest"),
            S("/coords-top → Set display position to Top"),
            S("/coords-middle → Set display position to Middle"),
            S("/coords-bottom → Set display position to Bottom"),
        }, "\n")
    end,
})

-- =====================
-- For changing the Mode
-- =====================

local function set_mode(name, requested_mode)
    local player = minetest.get_player_by_name(name)
    if not player then return false end
    local info = hud_ids[name]
    if not info then return false end
    info.mode = requested_mode
    return true
end

-- ==================================
-- The commands for changing the Mode 
-- ==================================

minetest.register_chatcommand("coords-mode1", {
    description = S("Hide coordinates"),
    func = function(name)
        if set_mode(name, "Coordinates-hidden") then
            return true, S("Coordinates hidden")
        end       
    end,
})

minetest.register_chatcommand("coords-mode2", {
    description = S("Show Position only"),
    func = function(name)
        if set_mode(name, "Position-only") then
            return true, S("Showing Position only")
        end
    end,
})

minetest.register_chatcommand("coords-mode3", {
    description = S("Show Position + Direction"),
    func = function(name)
        if set_mode(name, "Position-Direction") then
            return true, S("Showing Position + Direction")
        end
    end,
})

minetest.register_chatcommand("coords-mode4", {
    description = S("Show Position + Direction + Biome"),
    func = function(name)
        if set_mode(name, "Position-Direction-Biome") then
            return true, S("Showing Position + Direction + Biome")
        end        
    end,
})

-- ======================
-- For changing the Color
-- ======================

local function set_color(name, requested_color)
    local player = minetest.get_player_by_name(name)
    if not player then return false end
    local info = hud_ids[name]
    if not info then return false end
    player:hud_change(info.fg, "number", color_map[requested_color])
    return true 
end

-- ===================================
-- The commands for changing the Color
-- ===================================

minetest.register_chatcommand("coords-cyan", {
    description = S("Set coordinates color to Cyan"),
    func = function(name)
        if set_color(name, "Cyan") then
            return true, S("Coordinates color set to Cyan")
        end
    end,
})

minetest.register_chatcommand("coords-magenta", {
    description = S("Set coordinates color to Magenta"),
    func = function(name)
        if set_color(name, "Magenta") then
            return true, S("Coordinates color set to Magenta")
        end
    end,
})

minetest.register_chatcommand("coords-red", {
    description = S("Set coordinates color to Red"),
    func = function(name)
        if set_color(name, "Red") then
            return true, S("Coordinates color set to Red")
        end
    end,
})

minetest.register_chatcommand("coords-white", {
    description = S("Set coordinates color to White"),
    func = function(name)
        if set_color(name, "White") then
            return true, S("Coordinates color set to White")
        end
    end,
})

minetest.register_chatcommand("coords-yellow", {
    description = S("Set coordinates color to Yellow"),
    func = function(name)
        if set_color(name, "Yellow") then
            return true, S("Coordinates color set to Yellow")
        end
    end,
})

-- =================================
-- For changing the Size of the Text
-- =================================

local function set_mode(name, requested_size)
    local player = minetest.get_player_by_name(name)
    if not player then return false end
    local info = hud_ids[name]
    if not info then return false end
    player:hud_change(info.outline_top, "size", size_map[requested_size]) 
    player:hud_change(info.outline_bottom, "size", size_map[requested_size]) 
    player:hud_change(info.outline_left, "size", size_map[requested_size]) 
    player:hud_change(info.outline_right, "size", size_map[requested_size])     
    player:hud_change(info.fg, "size", size_map[requested_size]) 
    return true
end

-- ==============================================
-- The commands for changing the Size of the Text
-- ==============================================

minetest.register_chatcommand("coords-normal", {
    description = S("Set font size to Normal"),
    func = function(name)
        if set_mode(name, "Normal") then
            return true, S("Font size set to Normal")
        end       
    end,
})

minetest.register_chatcommand("coords-big", {
    description = S("Set font size to Big"),
    func = function(name)
        if set_mode(name, "Big") then
            return true, S("Font size set to Big")
        end       
    end,
})

minetest.register_chatcommand("coords-biggest", {
    description = S("Set font size to Biggest"),
    func = function(name)
        if set_mode(name, "Biggest") then
            return true, S("Font size set to Biggest")
        end       
    end,
})

-- ========================================
-- For changing the Position of the Display
-- ========================================

local function set_mode(name, requested_position)
    local player = minetest.get_player_by_name(name)
    if not player then return false end
    local info = hud_ids[name]
    if not info then return false end
    player:hud_change(info.outline_top, "position", position_map[requested_position]) 
    player:hud_change(info.outline_bottom, "position", position_map[requested_position]) 
    player:hud_change(info.outline_left, "position", position_map[requested_position]) 
    player:hud_change(info.outline_right, "position", position_map[requested_position])     
    player:hud_change(info.fg, "position", position_map[requested_position]) 
    return true
end

-- =====================================================
-- The commands for changing the Position of the Display
-- =====================================================

minetest.register_chatcommand("coords-top", {
    description = S("Set display position to Top"),
    func = function(name)
        if set_mode(name, "Top") then
            return true, S("Display position set to Top")
        end       
    end,
})

minetest.register_chatcommand("coords-middle", {
    description = S("Set display position to Middle"),
    func = function(name)
        if set_mode(name, "Middle") then
            return true, S("Display position set to Middle")
        end       
    end,
})

minetest.register_chatcommand("coords-bottom", {
    description = S("Set display position to Bottom"),
    func = function(name)
        if set_mode(name, "Bottom") then
            return true, S("Display position set to Bottom")
        end       
    end,
})
