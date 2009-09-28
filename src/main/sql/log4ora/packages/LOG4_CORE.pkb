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

-- DECLARE CONSTANTS
    cDBMS_OUTPUT CONSTANT VARCHAR2(11) := 'DBMS_OUTPUT';
    cAQ CONSTANT VARCHAR2(2) := 'AQ'; 
    cTRACE CONSTANT VARCHAR2(5) := 'TRACE';
    cDEBUG CONSTANT VARCHAR2(5) := 'DEBUG';
    cINFO CONSTANT VARCHAR2(4) := 'INFO';
    cWARN CONSTANT VARCHAR2(4) := 'WARN';
    cERROR CONSTANT VARCHAR2(5) := 'ERROR';
    cFATAL CONSTANT VARCHAR2(5) := 'FATAL';
 

-- return object with session data
    FUNCTION get_session_info
    RETURN session_info_type
    IS
    
        vSession_info session_info_type;
    
    BEGIN
    
      
        vSession_info := session_info_type( log4_globals.get_client_ip, 'sessionID', 
                        'OS User', 'host name', 'client_info', 'session_user' );
 
        RETURN vSession_info;
    END;


-- return object with system data
    FUNCTION get_system_info
    RETURN system_info_type
    IS
        vSystem_info system_info_type;
    
    BEGIN
        
        vSystem_info := system_info_type( 'scn', 'timestamp..', 'instanceid', 'db_name');
        
        RETURN vSystem_info;
    END;


-- return object with log message data
    FUNCTION get_message_info (pLevel IN VARCHAR2, pMsg IN VARCHAR2)
    RETURN message_info_type
    IS
    BEGIN
        RETURN  message_info_type (pLevel, pMsg); 
        
    END;


-- return object with exception data
    FUNCTION get_exception_info
    RETURN exception_info_type
    IS
        vException_info exception_info_type;
    BEGIN
        
        vException_info := exception_info_type ('err nbmr', 'error message here... ', 
                            'call stack here... ');

        RETURN vException_info;
    END;


-- build and return log message object
    FUNCTION get_log_message (pSession_info IN session_info_type,
                              pSystem_info  IN system_info_type,
                              pMessage_info IN message_info_type,
                              pException_info IN exception_info_type)
    RETURN log_message_type
    IS
    BEGIN
       
        RETURN log_message_type (pSession_info, pSystem_info, pMessage_info, pException_info);
    END ;                              

       
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
  FUNCTION is_log_level_enabled(pOwner IN VARCHAR2, pModule_name IN VARCHAR2, pLevel IN VARCHAR2,
    pLog_type IN VARCHAR2) RETURN boolean
  IS
    
    rLog_level log_level%rowtype;
    vLog_level CHAR(1);
    vReturn BOOLEAN := FALSE;
  
  BEGIN    
    -- look up log level 
    rLog_level := get_log_level(pOwner, pModule_name);
    
    -- if null result look up default log level 
    IF rLog_level.log_level_id IS NULL THEN         
        rLog_level := get_log_level('DEFAULT', 'DEFAULT');        
    END IF;
    
    IF rLog_level.log_level_id IS NULL THEN
        raise_application_error(-20001, 'Log Level not defined');
    END IF;
    
    -- get log level value from record
    CASE WHEN pLevel = cTRACE THEN vLog_level := rLog_level.trace;
         WHEN pLevel = cDEBUG THEN vLog_level := rLog_level.debug;
         WHEN pLevel = cINFO  THEN vLog_level := rLog_level.info;
         WHEN pLevel = cWARN  THEN vLog_level := rLog_level.warn;
         WHEN pLevel = cERROR THEN vLog_level := rLog_level.error;
         WHEN pLevel = cFATAL THEN vLog_level := rLog_level.fatal;
         ELSE raise_application_error(-20002, 'Invalid Log Level');     
    END CASE;
    
    -- determine if logging is enabled for log type
    IF pLog_type = cDBMS_OUTPUT THEN
        CASE WHEN vLog_level = '0' THEN vReturn := FALSE;
             WHEN vLog_level = '1' THEN vReturn := TRUE; 
             WHEN vLog_level = '2' THEN vReturn := FALSE;
             WHEN vLog_level = '3' THEN vReturn := TRUE;
             ELSE raise_application_error(-20003, 
                                           'Invalid Log Level Defined in Table');
        END CASE;     
    ELSIF pLog_type = cAQ THEN
        CASE WHEN vLog_level = '0' THEN vReturn := FALSE;
             WHEN vLog_level = '1' THEN vReturn := FALSE; 
             WHEN vLog_level = '2' THEN vReturn := TRUE;
             WHEN vLog_level = '3' THEN vReturn := TRUE;
             ELSE raise_application_error(-20003, 
                                           'Invalid Log Level Defined in Table');
        END CASE;     
    ELSE
        raise_application_error(-20004, 'Invalid Log Type passed for pLog_type:' 
                                          || pLog_type);
    END IF;    
    
    RETURN vReturn;
  END is_log_level_enabled;  
  


  /**
  *  This function gathers session information, and builds the XML message
  *  which will be placed on the queue.
  *
  */
  FUNCTION build_log_message (pLevel IN VARCHAR2, pMsg IN VARCHAR2) RETURN XMLTYPE IS
  
   vClient_IP VARCHAR(20);
   
   vLog_Message log_message_type; 
   
   vXML_Message XMLTYPE;
   
  BEGIN 
    
    -- TODOs
    -- get session info
    -- build xml message
    
    
    -- for testing of gloabals package, should drop variable assignment
 
    
    
    
    -- stub message for testing and development
    --vXML_Message := XMLTYPE('<MESSAGE>' || pMsg || '</MESSAGE>');
    
    --RETURN vXML_Message;
    
    vLog_message := get_log_message (get_session_info, 
                                     get_system_info,
                                     get_message_info (pLevel, pMsg),
                                     get_exception_info); 
                                    
    select sys_xmlgen(vLog_message) INTO vXML_message from dual;
    
       
    RETURN vXML_Message;                               
  END build_log_message;  


  /**
  * Procedure to insert log message to AQ Queue.
  *
  */ 
  PROCEDURE queue_message(pLevel IN VARCHAR2, pXML_Message IN XMLTYPE) IS
     vEnqueue_options    dbms_aq.enqueue_options_t;
     vMessage_properties dbms_aq.message_properties_t;
     vMessage            sys.aq$_jms_text_message;
     vMsgid              raw(16);
  BEGIN
    
    vMessage := sys.aq$_jms_text_message.construct;
    vMessage.set_text(pXML_Message.getClobVal());
    
    dbms_aq.enqueue ( queue_name         => 'log4ora.log_queue',
                        enqueue_options    => vEnqueue_options,
                        message_properties => vMessage_properties,
                        payload            => vMessage,
                        msgid              => vMsgid
                        );
    -- TO DO - add exception handling 
  END queue_message;
  

  /**
  * Severe errors that cause premature termination.
  *
  */  
  PROCEDURE fatal(pMsg IN VARCHAR2) IS
  
  BEGIN
   log_message(cFATAL, pMsg);
  END fatal;


  /**
  * Other runtime errors or unexpected conditions.
  *
  */  
  PROCEDURE error(pMsg IN VARCHAR2) IS
  
  BEGIN
    log_message(cERROR, pMsg);
  END error;
  
  
  /**
  * Use of deprecated APIs, poor use of API, 'almost' errors, other runtime situations 
  * that are undesirable or unexpected, but not necessarily "wrong".
  *
  */
  PROCEDURE warn(pMsg IN VARCHAR2) IS
  
  BEGIN
    log_message(cWARN, pMsg);
  END warn;
  
  
  /**
  * Interesting runtime events (startup/shutdown).
  *
  */
  PROCEDURE info(pMsg IN VARCHAR2) IS
  
  BEGIN
    log_message(cINFO, pMsg);
  END info;


  /**
  * Detailed information on the flow through the system.
  *
  */  
  PROCEDURE debug(pMsg IN VARCHAR2) IS
  
  BEGIN
    log_message(cDEBUG, pMsg);
  END debug;



  /**
  * More detailed information than debug.
  *
  */
  PROCEDURE trace(pMsg IN VARCHAR2) IS
  
  BEGIN
    log_message(cTRACE, pMsg);
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
    vXMLMessage XMLTYPE;
    
  BEGIN
    
    get_calling_module(vOwner, vModule, vLineNo);

    IF is_log_level_enabled(vOwner, vModule, pLevel, cDBMS_OUTPUT) THEN        
        dbms_output.put_line( to_char(sysdate, 'mm/dd/yyyy hh:mi:ss AM') 
                                 || '| ' || pLevel ||  ' | ' 
                                 || pMsg);
    END IF;
    
    IF is_log_level_enabled(vOwner, vModule, pLevel, cAQ) THEN    
        
        vXMLMessage := build_log_message(pLevel, pMsg);
        
        queue_message(pLevel, build_log_message(pLevel, pMsg));
    END IF;
    
  END log_message;
END log4_core;
/
