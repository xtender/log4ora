CREATE OR REPLACE PACKAGE BODY LOG4ORA.log4_globals AS
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

gClient_IP VARCHAR(20);


FUNCTION get_client_ip RETURN varchar2 IS
BEGIN
 
   IF gClient_IP IS NULL THEN
        gClient_IP := SYS_CONTEXT('USERENV', 'IP_ADDRESS');
   END IF;
   
   RETURN gClient_IP;
 
END;

END log4_globals;