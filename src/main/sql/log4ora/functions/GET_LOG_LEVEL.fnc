create or replace  FUNCTION log4ora.get_log_level(pOwner IN VARCHAR2, pModule_name IN VARCHAR2) 
/************************************************************************
    Log4ora - Logging package for Oracle 
    Copyright (C) 2009  John Thompson

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

************************************************************************/
    RETURN log_level%rowtype
    RESULT_CACHE RELIES_ON (LOG_LEVEL) -- result cache not supported for 
                                       -- for functions within packages
  IS
    rLog_level log_level%rowtype;
  BEGIN
    SELECT * INTO rLog_Level 
    FROM log_level
    WHERE owner = pOwner
      AND object = pModule_name;
  
    RETURN rLog_level;
  EXCEPTION 
    WHEN no_data_found THEN
        RETURN rLog_level;
    WHEN others THEN 
        raise;      
  END get_log_level;