local module = {
    name          = "luaextra",
    version       = 0.9,
    date          = "2009/03/19",
    description   = "Additions to the default lua library.",
    author        = "Hans Hagen, PRAGMA-ADE, Hasselt NL & Elie Roux",
    copyright     = "PRAGMA ADE / ConTeXt Development Team",
    license       = "GPLv2",
}

luatextra.provides_module(module)

string.chr_to_esc = {
    ["%"] = "%%",
    ["."] = "%.", ["*"] = "%*",
    ["+"] = "%+", ["-"] = "%-",
    ["^"] = "%^", ["$"] = "%$",
    ["["] = "%[", ["]"] = "%]",
    ["("] = "%(", [")"] = "%)",
    ["{"] = "%{", ["}"] = "%}"
}

function string:esc() -- variant 2
    return (self:gsub("(.)",string.chr_to_esc))
end

function string:count(pattern)
    local n = 0
    for _ in self:gmatch(pattern) do
        n = n + 1
    end
    return n
end

function string:stripspaces()
    return (self:gsub("^%s*(.-)%s*$", "%1"))
end

function string.is_boolean(str)
    if type(str) == "string" then
        if str == "true" or str == "yes" or str == "on" or str == "t" then
            return true
        elseif str == "false" or str == "no" or str == "off" or str == "f" then
            return false
        end
    end
    return nil
end

function string.is_number(str)
    return str:find("^[%-%+]?[%d]-%.?[%d+]$") == 1
end

lpeg.space    = lpeg.S(" \t\f\v")
lpeg.newline  = lpeg.P("\r\n") + lpeg.P("\r") +lpeg.P("\n")

if not table.fastcopy then do

    local type, pairs, getmetatable, setmetatable = type, pairs, getmetatable, setmetatable

    local function fastcopy(old) -- fast one
        if old then
            local new = { }
            for k,v in pairs(old) do
                if type(v) == "table" then
                    new[k] = fastcopy(v) -- was just table.copy
                else
                    new[k] = v
                end
            end
            local mt = getmetatable(old)
            if mt then
                setmetatable(new,mt)
            end
            return new
        else
            return { }
        end
    end

    table.fastcopy = fastcopy

end end

if not table.copy then do

    local type, pairs, getmetatable, setmetatable = type, pairs, getmetatable, setmetatable

    local function copy(t, tables) -- taken from lua wiki, slightly adapted
        tables = tables or { }
        local tcopy = {}
        if not tables[t] then
            tables[t] = tcopy
        end
        for i,v in pairs(t) do -- brrr, what happens with sparse indexed
            if type(i) == "table" then
                if tables[i] then
                    i = tables[i]
                else
                    i = copy(i, tables)
                end
            end
            if type(v) ~= "table" then
                tcopy[i] = v
            elseif tables[v] then
                tcopy[i] = tables[v]
            else
                tcopy[i] = copy(v, tables)
            end
        end
        local mt = getmetatable(t)
        if mt then
            setmetatable(tcopy,mt)
        end
        return tcopy
    end

    table.copy = copy

end end

function table.sortedkeys(tab)
    local srt, kind = { }, 0 -- 0=unknown 1=string, 2=number 3=mixed
    for key,_ in pairs(tab) do
        srt[#srt+1] = key
        if kind == 3 then
            -- no further check
        else
            local tkey = type(key)
            if tkey == "string" then
            --  if kind == 2 then kind = 3 else kind = 1 end
                kind = (kind == 2 and 3) or 1
            elseif tkey == "number" then
            --  if kind == 1 then kind = 3 else kind = 2 end
                kind = (kind == 1 and 3) or 2
            else
                kind = 3
            end
        end
    end
    if kind == 0 or kind == 3 then
        table.sort(srt,function(a,b) return (tostring(a) < tostring(b)) end)
    else
        table.sort(srt)
    end
    return srt
end

do
    table.serialize_functions = true
    table.serialize_compact   = true
    table.serialize_inline    = true

    local function key(k)
        if type(k) == "number" then -- or k:find("^%d+$") then
            return "["..k.."]"
        elseif noquotes and k:find("^%a[%a%d%_]*$") then
            return k
        else
            return '["'..k..'"]'
        end
    end

    local function simple_table(t)
        if #t > 0 then
            local n = 0
            for _,v in pairs(t) do
                n = n + 1
            end
            if n == #t then
                local tt = { }
                for i=1,#t do
                    local v = t[i]
                    local tv = type(v)
                    if tv == "number" or tv == "boolean" then
                        tt[#tt+1] = tostring(v)
                    elseif tv == "string" then
                        tt[#tt+1] = ("%q"):format(v)
                    else
                        tt = nil
                        break
                    end
                end
                return tt
            end
        end
        return nil
    end

    local function serialize(root,name,handle,depth,level,reduce,noquotes,indexed)
        handle = handle or print
        reduce = reduce or false
        if depth then
            depth = depth .. " "
            if indexed then
                handle(("%s{"):format(depth))
            else
                handle(("%s%s={"):format(depth,key(name)))
            end
        else
            depth = ""
            local tname = type(name)
            if tname == "string" then
                if name == "return" then
                    handle("return {")
                else
                    handle(name .. "={")
                end
            elseif tname == "number" then
                handle("[" .. name .. "]={")
            elseif tname == "boolean" then
                if name then
                    handle("return {")
                else
                    handle("{")
                end
            else
                handle("t={")
            end
        end
        if root and next(root) then
            local compact = table.serialize_compact
            local inline  = compact and table.serialize_inline
            local first, last = nil, 0 -- #root cannot be trusted here
            if compact then
              for k,v in ipairs(root) do -- NOT: for k=1,#root do (why)
                    if not first then first = k end
                    last = last + 1
                end
            end
            for _,k in pairs(table.sortedkeys(root)) do
                local v = root[k]
                local t = type(v)
                if compact and first and type(k) == "number" and k >= first and k <= last then
                    if t == "number" then
                        handle(("%s %s,"):format(depth,v))
                    elseif t == "string" then
                        if reduce and (v:find("^[%-%+]?[%d]-%.?[%d+]$") == 1) then
                            handle(("%s %s,"):format(depth,v))
                        else
                            handle(("%s %q,"):format(depth,v))
                        end
                    elseif t == "table" then
                        if not next(v) then
                            handle(("%s {},"):format(depth))
                        elseif inline then
                            local st = simple_table(v)
                            if st then
                                handle(("%s { %s },"):format(depth,table.concat(st,", ")))
                            else
                                serialize(v,k,handle,depth,level+1,reduce,noquotes,true)
                            end
                        else
                            serialize(v,k,handle,depth,level+1,reduce,noquotes,true)
                        end
                    elseif t == "boolean" then
                        handle(("%s %s,"):format(depth,tostring(v)))
                    elseif t == "function" then
                        if table.serialize_functions then
                            handle(('%s loadstring(%q),'):format(depth,string.dump(v)))
                        else
                            handle(('%s "function",'):format(depth))
                        end
                    else
                        handle(("%s %q,"):format(depth,tostring(v)))
                    end
                elseif k == "__p__" then -- parent
                    if false then
                        handle(("%s __p__=nil,"):format(depth))
                    end
                elseif t == "number" then
                    handle(("%s %s=%s,"):format(depth,key(k),v))
                elseif t == "string" then
                    if reduce and (v:find("^[%-%+]?[%d]-%.?[%d+]$") == 1) then
                        handle(("%s %s=%s,"):format(depth,key(k),v))
                    else
                        handle(("%s %s=%q,"):format(depth,key(k),v))
                    end
                elseif t == "table" then
                    if not next(v) then
                        handle(("%s %s={},"):format(depth,key(k)))
                    elseif inline then
                        local st = simple_table(v)
                        if st then
                            handle(("%s %s={ %s },"):format(depth,key(k),table.concat(st,", ")))
                        else
                            serialize(v,k,handle,depth,level+1,reduce,noquotes)
                        end
                    else
                        serialize(v,k,handle,depth,level+1,reduce,noquotes)
                    end
                elseif t == "boolean" then
                    handle(("%s %s=%s,"):format(depth,key(k),tostring(v)))
                elseif t == "function" then
                    if table.serialize_functions then
                        handle(('%s %s=loadstring(%q),'):format(depth,key(k),string.dump(v)))
                    else
                        handle(('%s %s="function",'):format(depth,key(k)))
                    end
                else
                    handle(("%s %s=%q,"):format(depth,key(k),tostring(v)))
                --  handle(('%s %s=loadstring(%q),'):format(depth,key(k),string.dump(function() return v end)))
                end
            end
            if level > 0 then
                handle(("%s},"):format(depth))
            else
                handle(("%s}"):format(depth))
            end
        else
            handle(("%s}"):format(depth))
        end
    end

    function table.serialize(root,name,reduce,noquotes)
        local t = { }
        local function flush(s)
            t[#t+1] = s
        end
        serialize(root, name, flush, nil, 0, reduce, noquotes)
        return table.concat(t,"\n")
    end

    function table.tostring(t, name)
        return table.serialize(t, name)
    end

    function table.tohandle(handle,root,name,reduce,noquotes)
        serialize(root, name, handle, nil, 0, reduce, noquotes)
    end

    -- sometimes tables are real use (zapfino extra pro is some 85M) in which
    -- case a stepwise serialization is nice; actually, we could consider:
    --
    -- for line in table.serializer(root,name,reduce,noquotes) do
    --    ...(line)
    -- end
    --
    -- so this is on the todo list

    table.tofile_maxtab = 2*1024

    function table.tofile(filename,root,name,reduce,noquotes)
        local f = io.open(filename,'w')
        if f then
            local concat = table.concat
            local maxtab = table.tofile_maxtab
            if maxtab > 1 then
                local t = { }
                local function flush(s)
                    t[#t+1] = s
                    if #t > maxtab then
                        f:write(concat(t,"\n"),"\n") -- hm, write(sometable) should be nice
                        t = { }
                    end
                end
                serialize(root, name, flush, nil, 0, reduce, noquotes)
                f:write(concat(t,"\n"),"\n")
            else
                local function flush(s)
                    f:write(s,"\n")
                end
                serialize(root, name, flush, nil, 0, reduce, noquotes)
            end
            f:close()
        end
    end

end

function table.tohash(t)
    local h = { }
    for _, v in pairs(t) do -- no ipairs here
        h[v] = true
    end
    return h
end

function table.fromhash(t)
    local h = { }
    for k, v in pairs(t) do -- no ipairs here
        if v then h[#h+1] = k end
    end
    return h
end

function table.contains_value(t, val)
    if t then
        for k, v in pairs(t) do
            if v==val then
                return true
            end
        end
    end
    return false
end

function table.contains_key(t, key)
    if t then
        for k, v in pairs(t) do
            if k==key then
                return true
            end
        end
    end
    return false
end

function table.value_position(t, val)
    if t then
        local i=1
        for k, v in pairs(t) do
            if v==val then
                return i
            end
            i=i+1
        end
    end
    return 0
end

function table.key_position(t, key)
    if t then
        local i=1
        for k,v in pairs(t) do
            if k==key then
                return i
            end
            i = i+1
        end
    end
    return 0
end

function table.remove_value(t, v)
    table.remove(t, table.value_position(t,v))
end

function table.remove_key(t, k)
    table.remove(t, table.key_position(t,k))
end

function table.reverse_hash(h)
    local r = { }
    for k,v in next, h do
        r[v] = string.lower(string.gsub(k," ",""))
    end
    return r
end

function table.is_empty(t)
    return not t or not next(t)
end

function io.loaddata(filename)
    local f = io.open(filename,'rb')
    if f then
        local data = f:read('*all')
        f:close()
        return data
    else
        return nil
    end
end

function io.savedata(filename,data,joiner)
    local f = io.open(filename, "wb")
    if f then
        if type(data) == "table" then
            f:write(table.join(data,joiner or ""))
        elseif type(data) == "function" then
            data(f)
        else
            f:write(data)
        end
        f:close()
    end
end

fpath = { }

function fpath.removesuffix(filename)
    return filename:gsub("%.[%a%d]+$", "")
end

function fpath.addsuffix(filename, suffix)
    if not filename:find("%.[%a%d]+$") then
        return filename .. "." .. suffix
    else
        return filename
    end
end

function fpath.replacesuffix(filename, suffix)
    if not filename:find("%.[%a%d]+$") then
        return filename .. "." .. suffix
    else
        return (filename:gsub("%.[%a%d]+$","."..suffix))
    end
end

function fpath.dirname(name)
    return name:match("^(.+)[/\\].-$") or ""
end

function fpath.basename(fname)
    if not fname then
        return nil
    end
    return fname:match("^.+[/\\](.-)$") or fname
end

function fpath.nameonly(name)
    return ((name:match("^.+[/\\](.-)$") or name):gsub("%..*$",""))
end

function fpath.suffix(name)
    return name:match("^.+%.([^/\\]-)$") or  ""
end

function fpath.stripsuffix(name)
    return (name:gsub("%.[%a%d]+$",""))
end

function fpath.join(...)
    local pth = table.concat({...},"/")
    pth = pth:gsub("\\","/")
    local a, b = pth:match("^(.*://)(.*)$")
    if a and b then
        return a .. b:gsub("//+","/")
    end
    a, b = pth:match("^(//)(.*)$")
    if a and b then
        return a .. b:gsub("//+","/")
    end
    return (pth:gsub("//+","/"))
end

function fpath.split(str)
    local t = { }
    str = str:gsub("\\", "/")
    str = str:gsub("(%a):([;/])", "%1\001%2")
    for name in str:gmatch("([^;:]+)") do
        if name ~= "" then
            name = name:gsub("\001",":")
            t[#t+1] = name
        end
    end
    return t
end

function fpath.normalize_sep(str)
    return str:gsub("\\", "/")
end

function fpath.localize_sep(str)
    if os.type == 'windows' or type == 'msdos' then
        return str:gsub("/", "\\")
    else
        return str:gsub("\\", "/")
    end
end

function fpath.join(tab)
    return table.concat(tab,io.pathseparator) -- can have trailing //
end

-- should be made with lfs.attributes

function lfs.is_writable(name)
    local f = io.open(name, 'w')
    if f then
        f:close()
        return true
    else
        return false
    end
end

function lfs.is_readable(name)
    local f = io.open(name,'r')
    if f then
        f:close()
        return true
    else
        return false
    end
end

if not math.round then
    function math.round(x)
        return math.floor(x + 0.5)
    end
end

if not math.div then
    function math.div(n,m)
        return floor(n/m)
    end
end

if not math.mod then
    function math.mod(n,m)
        return n % m
    end
end
