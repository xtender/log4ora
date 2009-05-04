CREATE OR REPLACE PACKAGE LOG4ORA.log4_core AS
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


  /**
  *  Procedure to get the calling module. Uses DBMS_UTILITY.format_call_stack.
  * 
  *  NOTE: This assumes the calling module is the 3rd in the call stack.  
  *        The first two positions of the call stack should be log4ora. 
  *        Use of an additional wrapper procedure could break this logic.
  */
  PROCEDURE get_calling_module (pOwner         OUT VARCHAR2,
                                pModule_name   OUT VARCHAR2,
                                pLineno        OUT NUMBER);
                                
                                
  /**
  * Function to return a string array.  Pass string, and values for separator tokens
  */
  FUNCTION Tokenizer (p_string IN VARCHAR2, p_separators in VARCHAR2) RETURN dbms_sql.varchar2s;
  
  

  /**
  *  Function to determine if log level is enabled for module
  *
  */
  FUNCTION is_log_level_enabled(pOwner IN VARCHAR2, pModule_name IN VARCHAR2, pLevel IN VARCHAR2, pLog_type IN VARCHAR2) RETURN boolean;



  /**
  *  This function gathers session information, and builds the XML message
  *  which will be placed on the queue.
  *
  */
  FUNCTION build_log_message (pLevel IN VARCHAR2, pMsg IN VARCHAR2) RETURN XMLTYPE;

  /**
  * Procedure to insert log message to AQ Queue.
  *
  */ 
  PROCEDURE queue_message (pLevel IN VARCHAR2, pXML_Message IN XMLTYPE);


  /**
  * Severe errors that cause premature termination.
  *
  */  
  PROCEDURE fatal(pMsg IN VARCHAR2);


  /**
  * Other runtime errors or unexpected conditions.
  *
  */  
  PROCEDURE error(pMsg IN VARCHAR2);
  
  
  /**
  * Use of deprecated APIs, poor use of API, 'almost' errors, other runtime situations 
  * that are undesirable or unexpected, but not necessarily "wrong".
  *
  */
  PROCEDURE warn(pMsg IN VARCHAR2);
  
  
  /**
  * Interesting runtime events (startup/shutdown).
  *
  */
  PROCEDURE info(pMsg IN VARCHAR2);


  /**
  * Detailed information on the flow through the system.
  *
  */  
  PROCEDURE debug(pMsg IN VARCHAR2);



  /**
  * More detailed information than debug.
  *
  */
  PROCEDURE trace(pMsg IN VARCHAR2);


  
  /**
  * Common logging procedure.  This procedure is used by the various
  * 'log level' procedures.
  *
  */  
  PROCEDURE log_message(pLevel IN VARCHAR2, pMsg IN VARCHAR2);
  
END log4_core;
/
