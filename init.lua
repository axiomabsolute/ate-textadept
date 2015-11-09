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

local function append()
    insert_mode()
    buffer:char_right()
end

local function match_brace()
    local match = buffer:brace_match(buffer.current_pos)
    if (match ~= -1) then
        buffer.current_pos = match
        buffer.set_empty_selection(buffer.current_pos)
    end
end

local function page_down()
    buffer:page_down()
end

local function page_up()
    buffer:page_up()
end

local function paste(before)
    -- TODO: refactor to work with selections
    -- TODO: refactor to work with line-wise pastes
    -- fails at start/end of buffer
    local start = buffer.current_pos
    local text = ui.clipboard_text
    local is_line = string.match(text, "^\n.*\n$")

    local pastepos
    local adjustment = 0
    if (before) then 
        adjustment = string.len(text)
        if (is_line) then
            -- pastepos is beginning of line
            insert_mode()
            buffer:home()
            pastepos = buffer.current_pos
        else
            -- pastepos is before cursor
            insert_mode()
            pastepos = buffer.current_pos
        end
    else
        if (is_line) then
            -- pastepos is end of line
            append()
            buffer:line_end()
            pastepos = buffer.current_pos
        else
            -- pastepos is after cursor
            append()
            pastepos = buffer.current_pos
        end
    end

    buffer:paste()
    buffer.current_pos = start + adjustment
    command_mode()
end

local function indent(back)
    local currentpos = buffer.current_pos
    buffer:home()
    -- TODO: refactor to work with multiple selections
    -- TODO: refactor to account for Tabs vs spaces
    -- TODO: refactor to work with selections
    local adjustment
    if (back) then
        buffer:back_tab()
        adjustment = -2
    else 
        buffer:tab()
        adjustment = 2
    end
    buffer.current_pos = currentpos
    buffer.set_empty_selection(buffer.current_pos + adjustment)
end

local function undo()
    buffer:undo()
end

local function redo()
    buffer:redo()
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
    ["m"] = match_brace,
    A = line_append,
    ["H"] = {undefined, "H"},
    ["L"] = {undefined, "L"},
    ["J"] = page_down,
    ["K"] = page_up,
    a = append,
    [">"] = {indent, false},
    ["<"] = {indent, true},
    u = undo,
    U = redo,
    p = {paste, false},
    P = {paste, true}
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

