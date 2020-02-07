# About Java Logging

A new class will be created to manage logging in App Navigator Java components, of which there are presently two: 

1. API Server
1. WASController 

# Java Logger Class 

```
package com.ibm.kappnav; 





```

# Usage public class Logger { 

```
   private static boolean[] typeEnabled= new boolean[LogType.values().length];

   private static void setLogTypes(boolean value) { 
      for ( LogType type: LogType.values() ) { 
          typeEnabled[type.ordinal()]= value; 
      } 
   } 

   static { 
      setLogLevel(LogLevel.INFO); // set default 
   } 

   // end user requests log level to select log types captured in log 
   public enum LogLevel { NONE, WARNING, ERROR, INFO, DEBUG, ENTRY, ALL }; 
   
   // code specifies log type it is writing 
   public enum LogType { ENTRY, EXIT, INFO, WARNING, ERROR, DEBUG }; 

   // return log message as string 
   public static String getLogMessage(LogType logType, String logData) {
       return "["+logType+"] "+logData; 
   } 

   public static void log(LogType logType, String logData) {
      if ( typeEnabled[logType.ordinal()] ) System.out.println(getLogMessage(logType,logData)); 
   };

   // guard methods 
   public static boolean entryEnabled() { 
      return typeEnabled[LogType.ENTRY.ordinal()]; 
   }
   public static boolean exitEnabled() { 
      return typeEnabled[LogType.EXIT.ordinal()]; 
   }
   public static boolean infoEnabled() { 
      return typeEnabled[LogType.INFO.ordinal()]; 
   }
   public static boolean warningEnabled() { 
      return typeEnabled[LogType.WARNING.ordinal()]; 
   }
   public static boolean errorEnabled() { 
      return typeEnabled[LogType.ERROR.ordinal()]; 
   }
   public static boolean debugEnabled() { 
      return typeEnabled[LogType.DEBUG.ordinal()]; 
   }

   public static void setLogLevel(LogLevel level) {
      setLogTypes(false); 
      switch(level) { 
         case NONE:
            break;               
         case ERROR:
            typeEnabled[LogType.ERROR.ordinal()]= true;  
            break;
         case WARNING: 
            typeEnabled[LogType.ERROR.ordinal()]= true;  
            typeEnabled[LogType.WARNING.ordinal()]= true;  
            break;
         case INFO: 
            typeEnabled[LogType.ERROR.ordinal()]= true;  
            typeEnabled[LogType.WARNING.ordinal()]= true;  
            typeEnabled[LogType.INFO.ordinal()]= true;  
            break;
         case DEBUG: 
            typeEnabled[LogType.ERROR.ordinal()]= true;  
            typeEnabled[LogType.WARNING.ordinal()]= true;  
            typeEnabled[LogType.INFO.ordinal()]= true;  
            typeEnabled[LogType.ENTRY.ordinal()]= true;  
            typeEnabled[LogType.EXIT.ordinal()]= true;  
            break;
         case ENTRY: 
            setLogTypes(true); 
            break;
         case ALL:  
            setLogTypes(true); 
            break;
      }       
   }
   
}
```

```
public class UseLogger {

   public static void main(String argv[]) { 
      
      if ( Logger.errorEnabled() ) {  
            Logger.log(Logger.LogType.ERROR, "wow, an error"); 
      }

      Logger.setLogLevel(Logger.LogLevel.ALL); 

      if ( Logger.debugEnabled() ) {  
         Logger.log(Logger.LogType.DEBUG, "debug this: foo"); 
      } 
   }

} 


``` 
