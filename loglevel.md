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

## Multi-container PODs 

Some app navigator PODs have multiple containers - e.g. UI pod has both UI server and API server containers.  Logging level is for the entire POD.  This means when the user sets log level, for example 'debug',  for the 'ui' POD, that the same log level is set on both the UI server and the API server.  

## Container Initialization

Any container that does tracing must read the current logging value for its POD type and initialize it's logger accordingly.

## Replicas

Log levels will be set identically across all replicas of a deployment.  

## Implementation Details

### Controllers

Controllers must watch the kappnav CR and set their logger's log level when their trace setting is changed.  E.g. 

E.g. if the kappnav CR is updated to have this value: 

```
logging:
   controller: debug
```

Then the kappnav controller would set log level to 'debug' on it's logger. In contrast, other controller's, like the WASController or the kappnav operator, would take no action.

A controller is responsible to set the specified log level on the other containers in it's POD. E.g. the kappnav controller is responsible to set the specified log level both on it's own logger, as well as on the logger of the API server in its same POD. This is done by invoking the API server's logger REST API on the API.


### Servers 

Servers do not watch the kappnav CR.  Instead, they expose a logger API that can be called to set their logger level. E.g. 

```
host:port/context/logger?level=value
```

The kappnav controller is responsible to watch the kappnav CR for changes to the 
ui' logging field and set the log level on the UI server. If the UI server has multiple replicas, the controller must iterate over each of the UI server PODs and set the log level on each. 

E.g. if the kappnav CR is updated to:   

```
logging:
    controller: debug
    ui: entry 
```

The kappnav controller would:

1. set it's own log level to 'debug' 
1. call its own API server's logger REST API to set the same value
1. call the UI server's logger REST API to set the UI's log level to 'entry'. If the UI server has multiple replicas, the controller must iterate over each of the UI server PODs and set the log level on each.  

A server is responsible to set the specified log level on the other containers in it's POD. E.g. the UI is responsible to set the specified log level both on it's own logger, as well as on the logger of the API server in its same POD. This is done by invoking the API server's logger REST API.
