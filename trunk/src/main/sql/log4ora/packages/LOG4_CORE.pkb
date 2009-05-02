CREATE OR REPLACE PACKAGE BODY LOG4ORA.log4_core AS
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



    -- based on ask tom utility... 
    PROCEDURE who_called_me (owner      OUT VARCHAR2,
                             name       OUT VARCHAR2,
                             lineno     OUT NUMBER,
                             caller_t   OUT VARCHAR2)
    IS
       call_stack    VARCHAR2 (4096) DEFAULT DBMS_UTILITY.format_call_stack ;
       n             NUMBER;
       found_stack   BOOLEAN DEFAULT FALSE ;
       line          VARCHAR2 (255);
       cnt           NUMBER := 0;
       vTokens       dbms_sql.varchar2s;
       vModule       VARCHAR2(100);
       vModule_Type   VARCHAR2(100);
       
    BEGIN
       --
       LOOP
          n := INSTR (call_stack, CHR (10));
          EXIT WHEN (cnt = 3 OR n IS NULL OR n = 0);
          --
          line := SUBSTR (call_stack, 1, n - 1);
          call_stack := SUBSTR (call_stack, n + 1);

          --
          IF (NOT found_stack)
          THEN
             IF (line LIKE '%handle%number%name%')
             THEN
                found_stack := TRUE;
             END IF;
          ELSE
             cnt := cnt + 1;

             -- cnt = 1 is Header Row
             -- cnt = 2 is This package (logging core)
             -- cnt = 3 is Interface to logging package
             -- cnt = 4 is Their Caller
             IF (cnt = 4)
             THEN
              
                vTokens := tokenizer(line, ' ');
             
                lineno := TO_NUMBER (vTokens(2));
                line := SUBSTR (line, 21);

                /* 
                *  The DBMS_UTILITY.format_call_stack function 
                *  Returns a string something like this:  
                *
                *  ----- PL/SQL Call Stack -----
                *    object      line  object
                *    handle    number  name
                * 0x9f4ff770       143  package body LOG4ORA.LOG4_CORE
                */
 

                IF vTokens.last = 5 THEN
                     vModule_type := vTokens(3) || ' ' || vTokens(4); 
                     vModule := vTokens(5);
                ELSE
                    vModule_type := vTokens(3);
                    vModule := vTokens(5);
                END IF;    
                
                --dbms_output.put_line('vModule = ' || vModule);
                --dbms_output.put_line('vModule_type = ' || vModule_type);
                
                
                IF (vModule LIKE 'pr%')
                THEN
                   n := LENGTH ('procedure ');
                ELSIF (vModule LIKE 'fun%')
                THEN
                   n := LENGTH ('function ');
                ELSIF (vModule LIKE 'package body%')
                THEN
                   n := LENGTH ('package body ');
                ELSIF (vModule LIKE 'pack%')
                THEN
                   n := LENGTH ('package ');
                ELSIF (vModule LIKE 'anonymous%')
                THEN
                   n := LENGTH ('anonymous block ');
                ELSE
                   n := NULL;
                END IF;

                IF (n IS NOT NULL)
                THEN
                   caller_t := LTRIM (RTRIM (UPPER (SUBSTR (line, 1, n - 1))));
                ELSE
                   caller_t := 'TRIGGER';
                END IF;

                line := SUBSTR (line, NVL (n, 1));
                n := INSTR (line, '.');
                owner := LTRIM (RTRIM (SUBSTR (line, 1, n - 1)));
                name := vModule;
             END IF;
          END IF;
       END LOOP;
    END;


    FUNCTION Tokenizer (p_string VARCHAR2, p_separators in VARCHAR2)
    RETURN dbms_sql.varchar2s IS
        l_token_tbl dbms_sql.varchar2s;
        pattern varchar2(250);
        BEGIN

        pattern := '[^(' || p_separators || ')]+' ;

            SELECT   REGEXP_SUBSTR (p_string, pattern, 1, LEVEL) token
              BULK   COLLECT
              INTO   l_token_tbl
              FROM   DUAL
             WHERE   REGEXP_SUBSTR (p_string, pattern, 1, LEVEL) IS NOT NULL
        CONNECT BY   REGEXP_INSTR (p_string, pattern, 1, LEVEL) > 0;

        RETURN l_token_tbl;
    END Tokenizer;


    
  PROCEDURE debug(pMsg IN VARCHAR2) IS
    vOwner varchar2(30);
    vName VARCHAR2(30);
    vLineNo NUMBER;
    vCaller_t VARCHAR2(30);
  
  BEGIN
    dbms_output.put_line(pMsg);
    --dbms_output.put_line('');
    --dbms_output.put_line(DBMS_UTILITY.FORMAT_CALL_STACK);
    
    who_called_me(vOwner, vName, vLineNo, vCaller_t);
    
    dbms_output.put_line('vOwner=' || vOwner);
    dbms_output.put_line(vName);
    dbms_output.put_line(vLineNo);
    dbms_output.put_line(vCaller_t);
    
    
  END;  

END log4_core;
/
