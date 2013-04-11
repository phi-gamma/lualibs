-- 
--  This is file `lualibs.lua',
--  generated with the docstrip utility.
-- 
--  The original source files were:
-- 
--  lualibs.dtx  (with options: `lua')
--  This is a generated file.
--  
--  Copyright (C) 2009 by PRAGMA ADE / ConTeXt Development Team
--  
--  See ConTeXt's mreadme.pdf for the license.
--  
--  This work consists of the main source file lualibs.dtx
--  and the derived file lualibs.lua.
--  
module('lualibs-basic', package.seeall)

local lualibs_module = {
    name          = "lualibs-basic",
    version       = 1.01,
    date          = "2013/04/10",
    description   = "Basic Lua extensions, meta package.",
    author        = "Hans Hagen, PRAGMA-ADE, Hasselt NL & Elie Roux",
    copyright     = "PRAGMA ADE / ConTeXt Development Team",
    license       = "See ConTeXt's mreadme.pdf for the license",
}

local loadmodule = lualibs.loadmodule

loadmodule("lualibs-lua.lua")
loadmodule("lualibs-lpeg.lua")
loadmodule("lualibs-function.lua")
loadmodule("lualibs-string.lua")
loadmodule("lualibs-table.lua")
loadmodule("lualibs-boolean.lua")
loadmodule("lualibs-number.lua")
loadmodule("lualibs-math.lua")
loadmodule("lualibs-io.lua")
loadmodule("lualibs-os.lua")
loadmodule("lualibs-file.lua")
loadmodule("lualibs-md5.lua")
loadmodule("lualibs-dir.lua")
loadmodule("lualibs-unicode.lua")
loadmodule("lualibs-url.lua")
loadmodule("lualibs-set.lua")

-- these don’t look much basic to me:
--l-pdfview.lua
--l-xml.lua



--  End of File `lualibs.lua'.
