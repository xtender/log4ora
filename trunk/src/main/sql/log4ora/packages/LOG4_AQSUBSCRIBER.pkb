CREATE OR REPLACE PACKAGE BODY LOG4ORA.log4_aqsubscriber AS
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


-- take message in, parse XML, then parse to ORA object type
PROCEDURE parse_message_to_object (pMessage IN VARCHAR, 
                                   pLog_message OUT log4ora.log_message)
IS

vXML_Message XMLTYPE;

BEGIN

    vXML_Message := XMLTYPE(pMessage);
      
    vXML_Message.toObject(pLog_message);
      
END;



-- save message data to log table
PROCEDURE save_to_log (pLog_message IN log4ora.log_message)
IS
BEGIN

    -- TO DO - create table, create insert
    null;

END save_to_log; 


PROCEDURE callback_procedure(
                   context  RAW,
                   reginfo  SYS.AQ$_REG_INFO,
                   descr    SYS.AQ$_DESCRIPTOR,
                   payload  RAW,
                   payloadl NUMBER
                   ) AS
  
     vDequeue_options    DBMS_AQ.DEQUEUE_OPTIONS_T;
     vMessage_properties DBMS_AQ.MESSAGE_PROPERTIES_T;
     vMessageid     RAW(16);
     VPayload            sys.aq$_jms_text_message;
     
     vMessage_text VARCHAR2(10000);
     vLog_Message log4ora.log_message;
     
  
  BEGIN
  
     vDequeue_options.msgid := descr.msg_id;
     vDequeue_options.consumer_name := descr.consumer_name;
  
     DBMS_AQ.DEQUEUE(
            queue_name         => descr.queue_name,
            dequeue_options    => vDequeue_options,
            message_properties => vMessage_properties,
            payload            => vPayload,
            msgid              => vMessageid
            );
    
      vPayload.get_text(vMessage_text);
  
  
      -- TODO add exception handling for parse fail
      BEGIN      
        parse_message_to_object(vMessage_text, vLog_Message);
      EXCEPTION
        WHEN others THEN 
            null;  -- do something here!!  Create error message and log
      END;

      
     save_to_log(vLog_message);
     
     COMMIT;  --required because procedure will be called by Oracle

  END;
  
  
                                     


END log4_aqsubscriber;