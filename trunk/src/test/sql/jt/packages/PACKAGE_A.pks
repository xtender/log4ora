CREATE OR REPLACE PACKAGE jt.package_a AS
/*
*  This package is just used for testing.  It acts as a external application, 
*  which calls the log4ora procedures for logging messages
*
*/
    PROCEDURE fatal(pMsg IN VARCHAR2);
    
    PROCEDURE error(pMsg IN VARCHAR2);
    
    PROCEDURE warn(pMsg IN VARCHAR2);
    
    PROCEDURE info(pMsg IN VARCHAR2);
    
    PROCEDURE debug(pMsg IN VARCHAR2);
    
    PROCEDURE trace(pMsg IN VARCHAR2);

    PROCEDURE test_exception;

END package_a;
/