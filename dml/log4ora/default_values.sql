-- set default value for log levels

INSERT INTO log4ora.log_level (log_level_id, owner, object) 
VALUES (log4ora.log_level_seq.nextval, 'DEFAULT', 'DEFAULT');

COMMIT;