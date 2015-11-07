local function move_cursor_right()
    buffer:char_right()
end

local function move_cursor_left()
    buffer:char_left()
end

local function move_cursor_down()
    buffer:line_down()
end

local function move_cursor_up()
    buffer:line_up()
end

local function find(in_files)
    ui.find.in_files = in_files
    ui.find.focus()
end

local function line_end()
    buffer:line_end()
end

local function line_home()
    buffer:home_display()
end

local function undefined(k)
    ui.statusbar_text = "Key `" .. k .. "` not yet implemented"
end

local verb_untransitive = {
    l = move_cursor_right,
    h = move_cursor_left,
    j = move_cursor_down,
    k = move_cursor_up,
    ["/"] = find,
    ["^"] = line_home,
    ["$"] = line_end,
}

local verb_prepphrase = {
}

local preps = {
}

local nouns = {
}

local function insert_mode()
    keys.MODE = nil
    ui.statusbar_text = 'INSERT MODE'
end

local function command_mode()
    keys.MODE = "command_mode"
    ui.statusbar_text = 'COMMAND MODE'
end

-- Each grammar will use N nested loops to register each key binding, where N is number of words
keys['esc'] = command_mode
keys.MODE = 'command_mode' -- default mode
keys.command_mode = {
    ['i'] = insert_mode
}

for k,v in pairs(verb_untransitive) do 
    print("Registering " .. k)
    keys.command_mode[k] = v
end

