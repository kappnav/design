# About Golang Logging

A new function package will be created to manage logging in App Navigator Golang components, of which there are presently two: 

1. Controller
1. Operator  

# Golang Logging Function

```
type LogType int

const ( 
    NONE = 0
    WARNING = 1 
    ERROR = 2
    INFO = 3
    DEBUG = 4
    ENTRY = 5
    ALL = 6
}

func log(logType LogType, logData string)

``` 
