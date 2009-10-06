/* Formatted on 10/6/2009 5:24:24 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE PACKAGE BODY jt.package_a
AS

   PROCEDURE fatal (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4ora.log4.fatal (pMsg);
   END;
   

   PROCEDURE error (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4ora.log4.error (pMsg);
   END;
   

   PROCEDURE warn (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4ora.log4.warn (pMsg);
   END;


   PROCEDURE info (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4ora.log4.info (pMsg);
   END;
   
   

   PROCEDURE debug (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4ora.log4.debug (pMsg);
   END;


   PROCEDURE trace (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4ora.log4.trace (pMsg);
   END;
   
   PROCEDURE test_exception 
   IS
   BEGIN
    raise no_data_found;
   EXCEPTION
    WHEN no_data_found THEN
         log4ora.log4.error ('Test of no_data_found error');
   END test_exception;
   
END package_a;
/