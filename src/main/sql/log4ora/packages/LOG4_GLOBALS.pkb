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


-- use global vars to store client info.  This should 
-- allow value to get set for session on first call and avoid
-- further calls to the sys_context function.
gClient_IP VARCHAR(20);
gSession_ID VARCHAR2(20);
gOS_user VARCHAR(200);
gHost  VARCHAR2(100);
gClient_info VARCHAR2(100);
gSession_user VARCHAR2(100);
gInstance  VARCHAR2(100);
gInstance_name VARCHAR2(100);
gDB_NAME  VARCHAR2(100);


FUNCTION get_client_ip RETURN VARCHAR2 IS
BEGIN
 
   IF gClient_IP IS NULL THEN
        gClient_IP := SYS_CONTEXT('USERENV', 'IP_ADDRESS');
   END IF;
   
   RETURN gClient_IP;
END get_client_ip;



FUNCTION get_session_id RETURN VARCHAR2 IS
BEGIN
 
   IF gSession_id IS NULL THEN
        gSession_id := SYS_CONTEXT('USERENV', 'SESSIONID');
   END IF;
   
   RETURN gSession_id;
END get_session_id;



FUNCTION get_os_user RETURN VARCHAR2 IS
BEGIN
 
   IF gOS_User IS NULL THEN
        gOS_user := SYS_CONTEXT('USERENV', 'OS_USER');
   END IF;
   
   RETURN gOS_user;
END get_os_user;



FUNCTION get_host RETURN VARCHAR2 IS
BEGIN
 
   IF gHost IS NULL THEN
        gHost := SYS_CONTEXT('USERENV', 'HOST');
   END IF;
   
   RETURN gHost;
END get_host;



FUNCTION get_client_info RETURN VARCHAR2 IS
BEGIN
 
   IF gClient_info IS NULL THEN
        gClient_info := SYS_CONTEXT('USERENV', 'CLIENT_INFO');
   END IF;
   
   RETURN gClient_info;
END get_client_info;


FUNCTION get_session_user RETURN VARCHAR2 IS
BEGIN
 
   IF gSession_user IS NULL THEN
        gSession_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
   END IF;
   
   RETURN gSession_user;
END get_session_user;



FUNCTION get_instance RETURN VARCHAR2 IS
BEGIN
 
   IF gInstance IS NULL THEN
        gInstance := SYS_CONTEXT('USERENV', 'INSTANCE');
   END IF;
   
   RETURN gInstance;
END get_instance;


FUNCTION get_instance_name RETURN VARCHAR2 IS
BEGIN
 
   IF gInstance_name IS NULL THEN
        gInstance_name := SYS_CONTEXT('USERENV', 'INSTANCE_NAME');
   END IF;
   
   RETURN gInstance_name;
END get_instance_name;



FUNCTION get_db_name RETURN VARCHAR2 IS
BEGIN
 
   IF gDB_Name IS NULL THEN
        gDB_Name := SYS_CONTEXT('USERENV', 'DB_NAME');
   END IF;
   
   RETURN gDB_Name;
END get_db_name;

/*
instance VARCHAR2(30),
instance_name VARCHAR2(60),
db_name VARCHAR2(30)
*/

END log4_globals;