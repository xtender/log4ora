### Why yet another logging package? ###
There are several logging packages available for PL/SQL.  I've used LOG4PLSQL on several projects in the past.  This is a good logging package, but can be verbose to use, and several developers found it confusing.  The Java listener is a great approach to extend the messages to Log4J.  However, this uses DBMS pipes for propagation of the messages.  Problems with this approach is the pipe buffer can fill up and cause an exception, and in a RAC environment, you need one Java listener per RAC node.

We started the Log4Ora package to leverage good concepts from other logging packages, create an easy to use API, fully leverage features in 11g, and provide an enterprise class logging solution.


### I have my own logging package which writes to a table.  Why use this? ###
We've seen several home-grown logging packages.  Typically, they do not support the concept of log levels and often have no alerting capabilities. Another difficulty is access to the log table itself.  With compliance for regulations such as PCI, SAS-70, or SOX, the application development team may not have access to the production database.

Log4ora was written to leverage JMS (via AQ) and Log4J.  This creates a more open standard for message consumers to use.  For example, the application development team may wish to have the messages written to a log file.  This is a simple configuration option in Log4J.  Or the operations team may wish to receive alerts via Splunk on all ERROR or FATAL messages.  Again, there would be several ways to configure this.  By using the JMS standard and providing a Log4J message client, enterprises using log4ora will have many options on how to consume the log messages.


### Will adding logging affect the performance of my application? ###
Yes, there is always an associated overhead to logging.  This applies to any logging implementation.  Log4Ora will first check to see if the log level is enabled, and if so, then generate the log message and write it to AQ.  This allows you to have more verbose logging in development, and then just log critical events in production.

The generation of a log message is roughly the same cost as an insert into a table. Control of the your application process is returned once the message is on the AQ queue.  Your application process does not incur the cost of propagating the message to subscribers. This is handled by Oracle internally.  Naturally, the over all system incurs a cost, but the application thread does not.


### Is Log4ora easy to use? ###
Yes.  Below is sample code to create a debug message.

```
BEGIN
    LOG4ORA.log4.debug('Debug Message');
END;
```

As a developer, you do not need to do anything else.  The framework will capture the log level, system information such as the user logged in, the program called, IP, and timestamp.  Also, the Oracle error number, message, and call stack are captured for each message.


### If I'm trouble shooting a production problem, is there a way to enable debug messages on demand? ###
Yes.  The logging level is kept in a table, and is by program module.  This means you can turn up logging for a specific package, procedure, or function on demand.  The 11g Result cache is used to store the settings to minimize overhead on the system.


### Is there a way to generate an email alert on an exception? ###
Yes, this is why we added log4j as a client.  You can easily generate an email alert by using the Log4J SMTP appender.  See this link for an overview of other available appenders:  http://www.allapplabs.com/log4j/log4j_appenders.htm


===Our system admin would like the error messages sent to syslog or the NT event log.  Can this be done?=== Yes.  Again using one of the standard appenders for Log4J.