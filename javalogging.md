# About Java Logging

A new class will be created to manage logging in App Navigator Java components, of which there are presently two: 

1. API Server
1. WASController 

# Java Logger Class 

```
package com.ibm.kappnav; 


public class Logger { 

   // end user requests log level to select log types captured in log 
   public enum LogLevel { NONE, WARNING, ERROR, INFO, ENTRY, DEBUG, ALL }; 
   
   // code specifies log type it is writing 
   public enum LogType { ENTRY, EXIT, INFO, WARNING, ERROR, DEBUG }; 

   private static boolean[] enabled= new boolean[LogType.values().length];

   static {
       enabled[LogType.ERROR.ordinal()]= true;
       enabled[LogType.WARNING.ordinal()]= true;
       enabled[LogType.INFO.ordinal()]= true;
   } // set default

   // return log message as string 
   public static String getLogMessage(LogType logType, String logData) {
       return "["+logType+"] "+logData; 
   } 

   public static void log(LogType logType, String logData) {

      if ( enabled[logType.ordinal()] ) System.out.println(getLogMessage(logType,logData)); 

   };

   private static void setLogTypes(boolean value) { 

      for ( LogType type: LogType.values() ) { 
          enabled[type.ordinal()]= value; 
      } 

   } 

   public static void setLogLevel(String level) {

            level= level.toLowerCase(); 

            setLogTypes(false); 

            switch(level) { 

               case "none": 
                  break;               
               case "error":
                  enabled[LogType.ERROR.ordinal()]= true;  
                  break;
               case "warning": 
                  enabled[LogType.ERROR.ordinal()]= true;  
                  enabled[LogType.WARNING.ordinal()]= true;  
                  break;
               case "info": 
                  enabled[LogType.ERROR.ordinal()]= true;  
                  enabled[LogType.WARNING.ordinal()]= true;  
                  enabled[LogType.INFO.ordinal()]= true;  
                  break;
               case "entry": 
                  enabled[LogType.ERROR.ordinal()]= true;  
                  enabled[LogType.WARNING.ordinal()]= true;  
                  enabled[LogType.INFO.ordinal()]= true;  
                  enabled[LogType.ENTRY.ordinal()]= true;  
                  enabled[LogType.EXIT.ordinal()]= true;  
                  break;
               case "debug": 
                  setLogTypes(true); 
                  break;
               case "all": 
                  setLogTypes(true); 
                  break;

            } 
           
   } 
   
}


```

# Usage 

```
public class UseLogger {

   public static void main(String argv[]) { 

         Logger.log(Logger.LogType.ERROR, "wow, an error"); 

         Logger.setLogLevel("all"); 

         Logger.log(Logger.LogType.DEBUG, "debug this: foo"); 
   }

} 

``` 
