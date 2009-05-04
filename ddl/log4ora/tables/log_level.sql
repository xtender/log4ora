--drop TABLE LOG4ORA.log_level;

CREATE TABLE LOG4ORA.log_level
(
  log_level_id  NUMBER CONSTRAINT LOG_LEVEL_ID_NN NOT NULL,
  owner         VARCHAR2(30) CONSTRAINT OWNER_NN NOT NULL,
  object        VARCHAR2(30) CONSTRAINT OBJECT_NN NOT NULL,
  trace         CHAR(1) DEFAULT '0' CONSTRAINT TRACE_NN NOT NULL, 
  debug         CHAR(1) DEFAULT '0' CONSTRAINT DEBUG_NN NOT NULL ,
  info          CHAR(1) DEFAULT '0' CONSTRAINT INFO_NN NOT NULL,
  warn          CHAR(1) DEFAULT '0' CONSTRAINT WARN_NN NOT NULL,
  error         CHAR(1) DEFAULT '0' CONSTRAINT ERROR_NN NOT NULL,
  fatal         CHAR(1) DEFAULT '0' CONSTRAINT FATAL_NN NOT NULL
)
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
NOMONITORING;

COMMENT ON TABLE LOG4ORA.log_level IS 'Table to hold logging level for various modules';

COMMENT ON COLUMN LOG4ORA.log_level.owner IS 'Schema Owner';

COMMENT ON COLUMN LOG4ORA.log_level.object IS 'Program Module (procedure, pacakge, trigger, etc)';

COMMENT ON COLUMN LOG4ORA.log_level.trace IS 'Log Level 0=disabled, 1=dbms.output only, 2=AQ Only, 3=AQ and DBMS.Output';

COMMENT ON COLUMN LOG4ORA.log_level.debug IS 'Log Level 0=disabled, 1=dbms.output only, 2=AQ Only, 3=AQ and DBMS.Output';

COMMENT ON COLUMN LOG4ORA.log_level.info IS 'Log Level 0=disabled, 1=dbms.output only, 2=AQ Only, 3=AQ and DBMS.Output';

COMMENT ON COLUMN LOG4ORA.log_level.warn IS 'Log Level 0=disabled, 1=dbms.output only, 2=AQ Only, 3=AQ and DBMS.Output';

COMMENT ON COLUMN LOG4ORA.log_level.error IS 'Log Level 0=disabled, 1=dbms.output only, 2=AQ Only, 3=AQ and DBMS.Output';

COMMENT ON COLUMN LOG4ORA.log_level.fatal IS 'Log Level 0=disabled, 1=dbms.output only, 2=AQ Only, 3=AQ and DBMS.Output';


ALTER TABLE LOG4ORA.LOG_LEVEL ADD (
  CONSTRAINT check_trace
 CHECK (trace IN ('0', '1', '2', '3')),
  CONSTRAINT check_debug
 CHECK (debug in ('0', '1', '2', '3')),
   CONSTRAINT check_info
 CHECK (info in ('0', '1', '2', '3')),
   CONSTRAINT check_warn
 CHECK (warn in ('0', '1', '2', '3')),
   CONSTRAINT check_error
 CHECK (error in ('0', '1', '2', '3')),
   CONSTRAINT check_fatal
 CHECK (fatal in ('0', '1', '2', '3')),
  CONSTRAINT LOG_LEVEL_PK
 PRIMARY KEY
 (LOG_LEVEL_ID));
