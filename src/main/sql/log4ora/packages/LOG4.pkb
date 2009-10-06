CREATE OR REPLACE PACKAGE BODY LOG4ORA.log4 AS
/************************************************************************
    Log4ora - Logging package for Oracle 
    Copyright (C) 2009  John Thompson

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

************************************************************************/


   PROCEDURE fatal (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4_core.fatal (pMsg);
   END fatal;

   PROCEDURE error (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4_core.error (pMsg);
   END error;

   PROCEDURE warn (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4_core.warn (pMsg);
   END warn;

   PROCEDURE info (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4_core.info (pMsg);
   END info;

   PROCEDURE debug (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4_core.debug (pMsg);
   END debug;

   PROCEDURE trace (pMsg IN VARCHAR2)
   IS
   BEGIN
      log4_core.trace (pMsg);
   END trace;

END log4;
/