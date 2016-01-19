# Overview #

![http://log4ora.googlecode.com/svn/trunk/doc/log4ora_overview.png](http://log4ora.googlecode.com/svn/trunk/doc/log4ora_overview.png)
## Application layer ##
The application layer represents some type of PL/SQL module.  This can be a procedure, function, package, or trigger. This is the body of code which is implementing the logging.

## Log4Ora Interface ##
Log4Ora provides an API interface layer.  The API layer is used to call the various logging modules, and to provide exception handling.  Ideally, exceptions thrown in logging will not propagate to the application layer.

## Log4Ora Core ##
The core package is responsible for determining the log level and writing messages to a queue in Oracle AQ.

## Oracle AQ / JMS ##
Oracle AQ (Advanced Queuing) is utilized for routing of the messages.  A publish and subscribe model is leveraged to allow multiple message consumers.

## Log4Ora Base Subscribers ##
### Log Table Subscriber ###
The log table subscriber inserts the message data into an Oracle database table.  This table can then be queried like any other table in Oracle for research and reporting.

### Log4J Subscriber ###
The Log4J Subscriber processes the AQ Message through Log4J.  Log4J is a very popular open source logging framework and offers a number of logging options.

The use of Log4J enables a number log message destinations including (but not limited to):
  * file, which can be tailed or viewed by a log viewer such as chainsaw.
  * Network Socket, which could be used to send log data into a third party application such as splunk.
  * SMTP for generating email alerts.
  * system console, allowing near time viewing of log messages.

## Custom Subscribers ##
Through configuration of AQ, additional subscribers can be added.  The subscriber can be any application that is capable of consuming a JMS message.