# Logging Level

Logging for App Navigator internal components is controlled by the "logging" field in the kappnav CR.  Logging level affects the individual components.  There is a logging setting for each app navigator component type. 

```
logging: 
   apis: level
   controller: level 
   ui: level
   was-controller: level
   operator: level
```
   
The value of level is one of: 

1. none
1. error
1. warning
1. info
1. debug
1. entry
1. all

The default is info. 

Example: 

```
logging:
   ui: debug
```

The specified log level, designates which log types are written to the log.  See next section for log types. 

## Log Types 

The app navigator components write log data categorized by type. The types are: 

1. entry
1. exit
1. info
1. warning
1. error
1. debug

## Log Level Hierarchy 

The user requests the types of log data they want written to the log by specifying a log level.  The log levels cause 
one or more log types to be written according to the following hierarchy: 

| Requested Log Level   | Resultant Log Types Written to Log       | 
|-----------------------|------------------------------------------|
| none                  |                                          | 
| error                 | error                                    |
| warning               | error, warning                           |
| info                  | error, warning, info                     |
| debug                 | error, warning, info, debug              |
| entry                 | error, warning, info, entry, exit, debug |
| all                   | error, warning, info, entry, exit, debug |

## NLS Consideration

NLS will not be supported initially.  When it is time to support NLS,  the following types will be translated: 

1. info
1. warning
1. error

## Components used across different PODs  

The APIs component is used in multiple POD types - Controller, UI, etc.  When API logging is enabled, all API containers across all POD types write trace records. 

## Container Initialization

Any container that does tracing must read the current logging value for its POD type and initialize it's logger accordingly. The only exception is the UI container.  The UI container's log level setting is monitored by the APIs container in the same POD; when it detects a change to the UI component logging level, it makes a localhost call to the UI container to set the log level.

## Replicas

Log levels will be set identically across all replicas of a deployment.  
