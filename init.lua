local function undefined(k)
    ui.statusbar_text = "Key `" .. k .. "` not yet implemented"
end

local function insert_mode()
    keys.MODE = nil
    ui.statusbar_text = 'INSERT MODE'
    buffer.caret_style = buffer.CARETSTYLE_LINE
end

local function command_mode()
    keys.MODE = "command_mode"
    ui.statusbar_text = 'COMMAND MODE'
    buffer.caret_style = buffer.CARETSTYLE_BLOCK
end

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
    buffer:home()
end

local function line_append()
    buffer:line_end()
    insert_mode()
end

local function match_brace()
    local match = buffer:brace_match(buffer.current_pos)
    if (match ~= -1) then
        buffer.current_pos = match
        buffer.set_empty_selection(buffer.current_pos)
    end
end

local verb_untransitive = {
    i = insert_mode,
    l = move_cursor_right,
    h = move_cursor_left,
    j = move_cursor_down,
    k = move_cursor_up,
    ["/"] = find,
    ["^"] = line_home,
    ["$"] = line_end,
    ["%"] = match_brace,
    A = line_append,
}

local verb_prepphrase = {
}

local preps = {
}

local nouns = {
}

-- Each grammar will use N nested loops to register each key binding, where N is number of words
keys['esc'] = command_mode
keys.MODE = 'command_mode' -- default mode
buffer.caret_style = buffer.CARETSTYLE_BLOCK
keys.command_mode = {}

for k,v in pairs(verb_untransitive) do 
    print("Registering " .. k)
    keys.command_mode[k] = v
end

