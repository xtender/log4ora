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


    INSERT INTO log_table (
        log_table_id,
        log_level,
        log_message,
        module_name,
        ora_err_number,
        ora_err_message,
        ora_call_stack,
        client_ip,
        session_id,
        os_user,
        host,
        client_info,
        session_user,
        source_timestamp,
        instance,
        instance_name,
        db_name  
    ) VALUES (
        log_table_seq.nextval,
        pLog_message.message_info.log_level,
        substr(pLog_message.message_info.log_message, 1, 4000),
        pLog_message.message_info.module_name,
        pLog_message.exception_info.ora_err_number,
        substr(pLog_message.exception_info.ora_err_message, 1, 1000),
        substr(pLog_message.exception_info.ora_call_stack, 1, 4000),
        pLog_message.session_info.client_ip,
        pLog_message.session_info.session_id,
        pLog_message.session_info.os_user,
        pLog_message.session_info.host,
        pLog_message.session_info.client_info,
        pLog_message.session_info.session_user,
        to_timestamp_tz(pLog_message.system_info.timestamp , 'DD-MON-YYYY HH24:MI:SSxFF TZH:TZM'),
        pLog_message.system_info.instance,
        pLog_message.system_info.instance_name,
        pLog_message.system_info.db_name        
    ); 
END save_to_log; 


-- called by Oracle AQ upon message arrival
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
  
      BEGIN      
        parse_message_to_object(vMessage_text, vLog_Message);
      EXCEPTION
        WHEN others THEN           
            -- create new message object with error info.
            -- note this logs the message ID which can be used for research of error
            vLog_Message := log4_core.get_log_message(
                                 log4_core.get_session_info, 
                                 log4_core.get_system_info,                                
                                 log4_core.get_message_info ('ERROR', 
                                    ( 'Error processing message received. Message ID: '
                                        || vMessageId), 
                                        'LOG4_AQSUBSCRIBER'),
                                 log4_core.get_exception_info);  
      END;
      
      save_to_log(vLog_message);  -- errors raised here will propagate to Oracle
                                  -- and will be handled by AQ
     
      COMMIT;  --required because procedure will be called by Oracle
  END;
  
  
                                     
END log4_aqsubscriber;
