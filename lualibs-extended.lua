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

--[[doc--
Here we define some functions that fake the elaborate logging/tracking
mechanism Context provides.
--doc]]--
local error, logger
if luatexbase and luatexbase.provides_module then
  --- TODO test how those work out when running tex
  local __error,_,_,__logger = luatexbase.provides_module(lualibs_module)
  error  = __error
  logger = __logger
else
  local texiowrite    = texio.write
  local texiowrite_nl = texio.write_nl
  local stringformat  = string.format
  local mklog = function (t)
    local prefix = stringformat("[%s] ", t)
    return function (...)
      texiowrite_nl(prefix)
      texiowrite   (stringformat(...))
    end
  end
  error  = mklog"ERROR"
  logger = mklog"INFO"
end

--[[doc--
We temporarily put our own global table in place and restore whatever
we overloaded afterwards.
--doc]]--
local log_backup
local switch_logger = function ( )
  if _G.logs then
    log_backup = _G.logs
  end
  _G.logs    = {
    reporter = logger,
    newline  = function ( ) texiowrite_nl"" end,
  }
end

--[[doc--
Restore a backed up logger if appropriate.
--doc]]--
local restore_logger = function ( )
  if log_backup then _G.logs = log_backup end
end

local loadmodule = lualibs.loadmodule

loadmodule("lualibs-util-str.lua")--- string formatters (fast)
loadmodule("lualibs-util-tab.lua")--- extended table operations
loadmodule("lualibs-util-sto.lua")--- storage (hash allocation)
----------("lualibs-util-pck.lua")---!packers; necessary?
----------("lualibs-util-seq.lua")---!sequencers (function chaining)
----------("lualibs-util-mrg.lua")---!only relevant in mtx-package
loadmodule("lualibs-util-prs.lua")--- miscellaneous parsers; cool. cool cool cool
----------("lualibs-util-fmt.lua")---!column formatter (rarely used)
loadmodule("lualibs-util-dim.lua")--- conversions between dimensions
loadmodule("lualibs-util-jsn.lua")--- JSON parser


switch_logger()

----------("lualibs-trac-set.lua")---!generalization of trackers
----------("lualibs-trac-log.lua")---!logging
loadmodule("lualibs-trac-inf.lua")--- timing/statistics
loadmodule("lualibs-util-lua.lua")--- operations on lua bytecode

restore_logger()

-- vim:tw=71:sw=2:ts=2:expandtab
--  End of File `lualibs-extended.lua'.
