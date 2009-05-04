BEGIN
  
-- create subscriber for message queue and register pl/sql procedure for notification

     DBMS_AQADM.ADD_SUBSCRIBER (
        queue_name => 'log4ora.log_queue',
        subscriber => SYS.AQ$_AGENT(
                         'logtable',
                         NULL,
                         NULL )
        );
  
      DBMS_AQ.REGISTER (
         SYS.AQ$_REG_INFO_LIST(
            SYS.AQ$_REG_INFO(
               'LOG4ORA.LOG_QUEUE:LOGTABLE', -- schema, queue, subscriber
               DBMS_AQ.NAMESPACE_AQ,
               'plsql://LOG4ORA.LOG4_AQSUBSCRIBER.CALLBACK_PROCEDURE',
               HEXTORAW('FF')
               )
            ),
         1
         );
  END;
