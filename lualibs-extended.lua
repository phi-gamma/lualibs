--  This is file `lualibs-extended.lua',
module('lualibs-extended', package.seeall)

local lualibs_basic_module = {
  name          = "lualibs-extended",
  version       = 1.01,
  date          = "2013/04/10",
  description   = "Basic Lua extensions, meta package.",
  author        = "Hans Hagen, PRAGMA-ADE, Hasselt NL & Elie Roux",
  copyright     = "PRAGMA ADE / ConTeXt Development Team",
  license       = "See ConTeXt's mreadme.pdf for the license",
}

local error
if luatexbase and luatexbase.provides_module then
  local __error,_,_ = luatexbase.provides_module(lualibs_module)
  error = __error
else
  error = texio.write_nl
end

local loadmodule = lualibs.loadmodule

loadmodule("lualibs-util-str")
loadmodule("lualibs-util-tab")
loadmodule("lualibs-util-sto")
----------("lualibs-util-pck")--- packers; necessary?
----------("lualibs-util-seq")--- sequencers (function chaining)
----------("lualibs-util-mrg")--- only relevant in mtx-package
loadmodule("lualibs-util-prs")--- miscellaneous parsers; cool. cool cool cool
----------("lualibs-util-fmt")--- column formtatter (rarely used)
loadmodule("lualibs-util-dim")
loadmodule("lualibs-util-jsn")

--loadmodule("lualibs-util-lua")--- operations on lua bytecode
-- 
--  End of File `lualibs-extended.lua'.
