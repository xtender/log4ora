class BootStrap {

  def init = {servletContext ->

    //check default values, setup if not initalized
    if (Module.count() == 0) {
      setDefaultModule()

      if (LogLevel.count() == 0) {
        setDefaultLogLevels()
      }

      if (LogMethod.count() == 0) {
        setDefaultLogMethods()
        setupDebugLogger()
      }

    }

  }

  def destroy = {
  }


  def setDefaultModule = {
    new Module(owner: 'DEFAULT', object: 'DEFAULT').save()
  }

  def setDefaultLogLevels = {
    new LogLevel(levelCode: 'TRACE').save()
    new LogLevel(levelCode: 'DEBUG').save()
    new LogLevel(levelCode: 'INFO').save()
    new LogLevel(levelCode: 'ERROR').save()
    new LogLevel(levelCode: 'FATAL').save()
    new LogLevel(levelCode: 'WARN').save()
  }

  def setDefaultLogMethods = {
    new LogMethod(methodCode: 'LOG_TABLE', methodDescription: 'Log to database table via AQ').save()
    new LogMethod(methodCode: 'DBMS_OUTPUT', methodDescription: 'Write messages to DBMS_OUTPUT buffer').save()
    new LogMethod(methodCode: 'JMS_SUBSCRIBER', methodDescription: 'Send Log Message to JMS Subscriber').save()

  }

  def setupDebugLogger = {
    def module = Module.findByOwnerAndObject('DEFAULT', 'DEFAULT')

    def level = LogLevel.findByLevelCode('DEBUG')

    def method = LogMethod.findByMethodCode('LOG_TABLE')

    def moduleLevel = new ModuleLevel(module: module, level: level, loggingEnabled: 'Y')

    moduleLevel.addToModuleLevelMethod(new ModuleLevelMethod(moduleLevel: moduleLevel, logMethod: method))

    module.addToModuleLevels(moduleLevel)

    module.save()


  }


} 