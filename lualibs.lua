--  This is file `lualibs.lua',
module('lualibs', package.seeall)

local lualibs_module = {
  name          = "lualibs",
  version       = 1.01,
  date          = "2013/04/10",
  description   = "Lua additional functions.",
  author        = "Hans Hagen, PRAGMA-ADE, Hasselt NL & Elie Roux",
  copyright     = "PRAGMA ADE / ConTeXt Development Team",
  license       = "See ConTeXt's mreadme.pdf for the license",
}

local prefer_merged = true -- | false --- TODO should be set in some global config

local lpeg, kpse = lpeg, kpse

local dofile       = dofile
local lpegmatch    = lpeg.match
local stringformat = string.format

local find_file, error, warn, info
if luatexbase and luatexbase.provides_module then
  error, warn, info = luatexbase.provides_module(lualibs_module)
else
  error, warn, info = texio.write_nl, texio.write_nl, texio.write_nl -- stub
end
if luatexbase and luatexbase.find_file then
  find_file = luatexbase.find_file
else
  kpse.set_program_name"luatex"
  find_file = kpse.find_file
end

loadmodule = _ENV.loadmodule or function (name, t)
  if not t then t = "library" end
  local filepath  = kpse.find_file(name, "lua")
  if not filepath or filepath == "" then
    warn(stringformat("Could not locate %s “%s”.", t, name))
    return false
  end
  dofile(filepath)
  return true
end

local merged_suffix = "-merged.lua"

local p_suffix      = lpeg.P".lua" * lpeg.P(-1)
local p_nosuffix    = (1 - p_suffix)^0
local p_hassuffix   = (p_nosuffix) * p_suffix
local p_stripsuffix = lpeg.C(p_nosuffix) * p_suffix

local loadmerged = function (basename)
  basename = lualibs_module.name .. "-" .. basename
  if not lpegmatch(p_hassuffix, basename) then -- force .lua suffix
    basename = basename .. ".lua"
  end
  local res
  if prefer_merged then
    local mergedname = lpegmatch(p_stripsuffix, basename) .. merged_suffix
    res = loadmodule(mergedname, "merged package")
  else
    info"Ignoring merged packages."
  end
  if not res then -- package not present, load individual libs
    info(stringformat("Falling back to “%s”.", basename))
    res = loadmodule(basename, "metapackage")
  end
  if res == false then
    error(stringformat("Could not load metapackage “%s”.", basename))
  end
end

loadmerged"basic.lua"
--inspect(table.keys(table))
--inspect(table.keys(string))
loadmerged"extended.lua"

io.write"\n"
-- 
-- vim:tw=71:sw=2:ts=2:expandtab
--  End of File `lualibs-basic.lua'.
