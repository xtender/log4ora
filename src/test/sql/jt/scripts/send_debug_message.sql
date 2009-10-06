DECLARE 
  PMSG VARCHAR2(32767);

BEGIN 
  PMSG := 'debug message';

  JT.PACKAGE_A.DEBUG ( PMSG );
  COMMIT; 
END;