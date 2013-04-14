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

--- TODO should be set in some global config
prefer_merged       = true ---false
local load_extended = true ---false

if config and config.lualibs then
  local cl_prefer_merged = config.lualibs.prefer_merged
  local cl_load_extended = config.lualibs.load_extended
  if cl_prefer_merged ~= nil then prefer_merged = cl_prefer_merged end
  if cl_load_extended ~= nil then load_extended = cl_load_extended end
end

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

loadmodule = _G.loadmodule or function (name, t)
  if not t then t = "library" end
  local filepath  = kpse.find_file(name, "lua")
  if not filepath or filepath == "" then
    warn(stringformat("Could not locate %s “%s”.", t, name))
    return false
  end
  dofile(filepath)
  return true
end

--[[doc--
The separation of the “basic” from the “extended” sets coincides with
the split into luat-bas.mkiv and luat-lib.mkiv.
--doc]]--
loadmodule"lualibs-basic.lua"
loadmodule"lualibs-compat.lua" --- restore stuff gone since v1.*

if load_extended == true then
  loadmodule"lualibs-extended.lua"
end

-- vim:tw=71:sw=2:ts=2:expandtab
--  End of File `lualibs-basic.lua'.
