-- ########################### 
-- ###########################
-- THIS MUST BE RUN AS LOG4ORA USER
-- the XML DB does not do well with schema owners... 
-- register xml schema with oracle
DECLARE
vSchema VARCHAR2(5000) := 
'<?xml version="1.0" encoding="utf-8" ?>
<xs:schema xmlns="http://log4ora.googlecode.com/svn/trunk/xsd/logmessage.xsd" elementFormDefault="qualified" targetNamespace="http://log4ora.googlecode.com/svn/trunk/xsd/logmessage.xsd" version="1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="log_message" type="log_message_type" />
  <xs:complexType name="session_info_type">
    <xs:sequence>
      <xs:element minOccurs="1" maxOccurs="1" name="client_ip" type="xs:string" />
      <xs:element minOccurs="1" maxOccurs="1" name="session_id" type="xs:string" />
      <xs:element minOccurs="1" maxOccurs="1" name="os_user" type="xs:string" />
      <xs:element minOccurs="1" maxOccurs="1" name="host" type="xs:string" />
      <xs:element minOccurs="0" maxOccurs="1" name="client_identifier" type="xs:string" />
      <xs:element minOccurs="0" maxOccurs="1" name="client_info" type="xs:string" />
      <xs:element minOccurs="1" maxOccurs="1" name="session_user" type="xs:string" />
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="system_info_type">
    <xs:sequence>
      <xs:element minOccurs="1" maxOccurs="1" name="scn" type="xs:string" />
      <xs:element minOccurs="1" maxOccurs="1" name="timestamp" type="xs:dateTime" />
      <xs:element minOccurs="1" maxOccurs="1" name="instance" type="xs:string" />
      <xs:element minOccurs="1" maxOccurs="1" name="db_name" type="xs:string" />
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="message_info_type">
    <xs:sequence>
      <xs:element minOccurs="1" maxOccurs="1" name="log_level" type="xs:string" />
      <xs:element minOccurs="1" maxOccurs="1" name="log_message" type="xs:string" />
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="exception_info_type">
    <xs:sequence>
      <xs:element minOccurs="1" maxOccurs="1" name="ora_err_number" type="xs:string" />
      <xs:element minOccurs="1" maxOccurs="1" name="ora_err_message" type="xs:string" />
      <xs:element minOccurs="1" maxOccurs="1" name="ora_call_stack" type="xs:string" />
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="log_message_type">
    <xs:sequence>
      <xs:element minOccurs="1" maxOccurs="1" name="session_info" type="session_info_type" />
      <xs:element minOccurs="1" maxOccurs="1" name="system_info" type="system_info_type" />
      <xs:element minOccurs="1" maxOccurs="1" name="message_info" type="message_info_type" />
      <xs:element minOccurs="0" maxOccurs="1" name="exception_info" type="exception_info_type" />
    </xs:sequence>
  </xs:complexType>
</xs:schema>';

BEGIN
  DBMS_XMLSCHEMA.registerSchema(
    SCHEMAURL => 'http://log4ora.googlecode.com/svn/trunk/xsd/logmessage.xsd',
    SCHEMADOC => vSchema);
END;
/
