BEGIN 

  JT.PACKAGE_A.fatal ( 'fatal message');

  JT.PACKAGE_A.error ( 'error message' );

  JT.PACKAGE_A.warn ( 'warn message');

  JT.PACKAGE_A.info ( 'info message' );

  JT.PACKAGE_A.DEBUG ( 'debug message' );

  JT.PACKAGE_A.trace ( 'trace message' );

  JT.PACKAGE_A.test_exception;


  COMMIT; 
END;