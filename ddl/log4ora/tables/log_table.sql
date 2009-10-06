DROP TABLE LOG4ORA.log_table;

CREATE TABLE LOG4ORA.log_table
(
  log_table_id  NUMBER CONSTRAINT LOG_TABLE_ID_NN NOT NULL,
  log_level     VARCHAR2(20),
  log_message   VARCHAR2(4000),
  module_name   VARCHAR2(60),
  ora_err_number VARCHAR2(10),
  ora_err_message VARCHAR2(1000),
  ora_call_stack VARCHAR2(4000),
  client_ip VARCHAR2(20),
  session_id VARCHAR2(30),
  os_user VARCHAR2(200),
  host VARCHAR2(100),
  client_info VARCHAR2(100),
  session_user VARCHAR2(100),
  source_timestamp timestamp,
  instance VARCHAR2(30),
  instance_name VARCHAR2(60),
  db_name VARCHAR2(30),
  create_date DATE DEFAULT SYSDATE  
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
NOMONITORING;

COMMENT ON TABLE LOG4ORA.log_table IS 'Table to hold logging level for various modules';
COMMENT ON COLUMN LOG4ORA.log_table.log_level IS 'Log Level of Message';  
COMMENT ON COLUMN LOG4ORA.log_table.log_message IS 'Message body';    
COMMENT ON COLUMN LOG4ORA.log_table.module_name IS 'Name of program module';     
COMMENT ON COLUMN LOG4ORA.log_table.ora_err_number IS 'Oracle Err number';   
COMMENT ON COLUMN LOG4ORA.log_table.ora_err_message IS 'Oracle Error Message Text';   
COMMENT ON COLUMN LOG4ORA.log_table.ora_call_stack IS 'Program Call Stack';   
COMMENT ON COLUMN LOG4ORA.log_table.client_ip IS 'IP of Client';   
COMMENT ON COLUMN LOG4ORA.log_table.session_id  IS 'ID of Oracle Session';  
COMMENT ON COLUMN LOG4ORA.log_table.os_user IS 'OS User Account';   
COMMENT ON COLUMN LOG4ORA.log_table.host IS 'Client Host Machine Name';   
COMMENT ON COLUMN LOG4ORA.log_table.client_info IS 'Client Data';   
COMMENT ON COLUMN LOG4ORA.log_table.session_user IS 'Oracle user account';   
COMMENT ON COLUMN LOG4ORA.log_table.source_timestamp IS 'Timestamp from message';   
COMMENT ON COLUMN LOG4ORA.log_table.instance IS 'RAC instance';   
COMMENT ON COLUMN LOG4ORA.log_table.instance_name IS 'RAC instance name';   
COMMENT ON COLUMN LOG4ORA.log_table.db_name IS 'DB SID name';   
COMMENT ON COLUMN LOG4ORA.log_table.create_date IS 'date/time of record creation';   


ALTER TABLE LOG4ORA.log_table ADD (
  CONSTRAINT LOG_table_PK
 PRIMARY KEY
 (LOG_TABLE_ID));