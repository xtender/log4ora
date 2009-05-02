CREATE OR REPLACE PACKAGE jt.package_a AS
/*
*  This package is just used for testing.  It acts as a external application, 
*  which calls the log4ora procedures for logging messages
*
*/
  PROCEDURE debug(pMsg IN VARCHAR2);

END package_a;
/