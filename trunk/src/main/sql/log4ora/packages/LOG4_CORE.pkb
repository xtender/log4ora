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


    --  roughly based on an 'ask tom' utility... 
    PROCEDURE get_calling_module (pOwner      OUT VARCHAR2,
                             pModule_name       OUT VARCHAR2,
                             pLineno     OUT NUMBER)
    IS
       vCall_stack    VARCHAR2(2000) DEFAULT DBMS_UTILITY.format_call_stack ;
       n             NUMBER;
       found_stack   BOOLEAN DEFAULT FALSE;
       line        varchar2(255);
       cnt         number := 0;
       vTokens       dbms_sql.varchar2s;
       vModule       VARCHAR2(100);
       vModule_Type   VARCHAR2(100);
       vProcedure_name VARCHAR2(30);
       vDbLink        VARCHAR(30);
       vNextPos      BINARY_INTEGER;
       
    BEGIN
       
       LOOP
          n := INSTR (vCall_stack, CHR (10));
          EXIT WHEN (cnt = 50 OR n IS NULL OR n = 0);
          
          line := SUBSTR (vCall_stack, 1, n - 1);
          vCall_stack := SUBSTR (vCall_stack, n + 1);

          IF (NOT found_stack)
          THEN
             IF (line LIKE '%handle%number%name%')
             THEN
                found_stack := TRUE;
             END IF;
          ELSE
            cnt := cnt + 1;
              
            vTokens := tokenizer(line, ' ');
             
            /* 
            *  The DBMS_UTILITY.format_call_stack function 
            *  Returns a string something like this:  
            *
            * ----- PL/SQL Call Stack -----
            *  object      line  object
            *handle    number  name
            *0x9f4ff770        27  package body LOG4ORA.LOG4_CORE
            *0x9f4ff770       243  package body LOG4ORA.LOG4_CORE
            *0x9f4ff770       215  package body LOG4ORA.LOG4_CORE
            *0x94df0178        23  package body LOG4ORA.LOG4
            *0xa7950748         5  package body JT.PACKAGE_A
            */
 
            -- module name will shift due to word count of type
            IF vTokens.last = 5 THEN
                 --vModule_type := vTokens(3) || ' ' || vTokens(4); 
                 vModule := vTokens(5);
            ELSE
                --vModule_type := vTokens(3);
                vModule := vTokens(4);
            END IF;    
                
            IF vModule != 'LOG4ORA.LOG4_CORE' and vModule != 'LOG4ORA.LOG4' THEN
                EXIT; --found caller, exit loop
            END IF;    

          END IF;
       END LOOP;
       
       pLineno := vTokens(2);
       
       -- util to parse name string returned
       dbms_utility.name_tokenize(vModule, pOwner, pModule_name, vProcedure_name, vDBLink, vNextPos );
       
    END get_calling_module;


    FUNCTION Tokenizer (p_string IN VARCHAR2, p_separators in VARCHAR2)
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



  /**
  *  Function to determine if log level is enabled for module
  *
  */
  FUNCTION is_log_level_enabled(pOwner IN VARCHAR2, pModule_name IN VARCHAR2, pLevel IN VARCHAR2) RETURN boolean IS
  BEGIN
  
    -- look up log level 
    RETURN TRUE;
  END is_log_level_enabled;  
  

  /**
  *  This function gathers session information, and builds the XML message
  *  which will be placed on the queue.
  *
  */
  FUNCTION build_log_message (pLevel IN VARCHAR2, pMsg IN VARCHAR2) RETURN VARCHAR2 IS
  
   vClient_IP VARCHAR(20);
  BEGIN 
    
    -- TODOs
    -- get session info
    -- build xml message
    -- maybe this should return an xmltype??
    
    -- for testing of gloabals package, should drop variable assignment
    vClient_IP := log4_globals.get_client_ip;
    
    RETURN pMsg;
  END build_log_message;  


  /**
  * Procedure to insert log message to AQ Queue.
  *
  */ 
  PROCEDURE queue_message(pLevel IN VARCHAR2, pMessage IN VARCHAR2) IS
  BEGIN
  
    -- insert into AQ here
    null;
  END queue_message;
  

  /**
  * Severe errors that cause premature termination.
  *
  */  
  PROCEDURE fatal(pMsg IN VARCHAR2) IS
  
  BEGIN
    null;
  END fatal;


  /**
  * Other runtime errors or unexpected conditions.
  *
  */  
  PROCEDURE error(pMsg IN VARCHAR2) IS
  
  BEGIN
    null;
  END error;
  
  
  /**
  * Use of deprecated APIs, poor use of API, 'almost' errors, other runtime situations 
  * that are undesirable or unexpected, but not necessarily "wrong".
  *
  */
  PROCEDURE warn(pMsg IN VARCHAR2) IS
  
  BEGIN
    null;
  END warn;
  
  
  /**
  * Interesting runtime events (startup/shutdown).
  *
  */
  PROCEDURE info(pMsg IN VARCHAR2) IS
  
  BEGIN
    null;
  END info;


  /**
  * Detailed information on the flow through the system.
  *
  */  
  PROCEDURE debug(pMsg IN VARCHAR2) IS
  
  BEGIN
    log_message('DEBUG', pMsg);
  END debug;



  /**
  * More detailed information than debug.
  *
  */
  PROCEDURE trace(pMsg IN VARCHAR2) IS
  
  BEGIN
    null;
  END trace;


  /**
  * Common logging procedure.  This procedure is used by the various
  * 'log level' procedures.
  *
  */  
  PROCEDURE log_message(pLevel IN VARCHAR2, pMsg IN VARCHAR2) IS
    vOwner VARCHAR2(30);
    vModule VARCHAR2(30);
    vLineNo NUMBER;
    
  BEGIN
    
    get_calling_module(vOwner, vModule, vLineNo);

    
    IF is_log_level_enabled(vOwner, vModule, pLevel) THEN        
        queue_message(pLevel, build_log_message(pLevel, pMsg));
    END IF;
    
  END log_message;
END log4_core;
/
