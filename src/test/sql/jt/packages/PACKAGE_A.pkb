


CREATE OR REPLACE PACKAGE BODY jt.package_a AS
    
  PROCEDURE debug(pMsg IN VARCHAR2) IS
  BEGIN
    log4ora.log4.debug(pMsg); 
  END;  

END package_a;
/
