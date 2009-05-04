
-- create queue table and queue for log messages
BEGIN
    dbms_aqadm.create_queue_table
    ( queue_table        => 'log4ora.log_queue_table',
      queue_payload_type => 'sys.aq$_jms_text_message',
      multiple_consumers => TRUE      
    );
    dbms_aqadm.create_queue
    ( queue_name  => 'log4ora.log_queue'
    , queue_table => 'log4ora.log_queue_table'
    );
    dbms_aqadm.start_queue
    ( queue_name => 'log4ora.log_queue'
    );
  end;
  /