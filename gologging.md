# About Golang Logging

A new function package will be created to manage logging in App Navigator Golang components, of which there are presently two: 

1. Controller
1. Operator  

# Golang Logging Function

```
type LogLevel int

/* values of LogLevel 

   LogLevel is what user requests 
*/
const ( 
    LOG_LEVEL_NONE LogLevel = 0
    LOG_LEVEL_WARNING LogLevel = 1 
    LOG_LEVEL_ERROR LogLevel = 2
    LOG_LEVEL_INFO LogLevel = 3
    LOG_LEVEL_DEBUG LogLevel = 4
    LOG_LEVEL_ENTRY LogLevel = 5
    LOG_LEVEL_ALL LogLevel = 6
)

type LogType int 

/* values of LogType 

   LogType is how code categorizes log message

*/

const (
    LOG_TYPE_ENTRY LogType = 0
    LOG_TYPE_EXIT LogType = 1
    LOG_TYPE_INFO LogType = 2
    LOG_TYPE_WARNING LogType = 3
    LOG_TYPE_ERROR LogType = 4
    LOG_TYPE_DEBUG LogType = 5
)

/* global variable holds current log level */
var g_logLevel LogLevel = INFO; /* default */

/* global variable to hold current log type enablement flags */ 
var g_logTypeEnabled [6]bool 

/* init logging 
   call setLevel(g_logLevel)to init logging type enablement 
*/ 
func initLogging() 

/* set global log level to specified value 

   set g_logTypeEnabled based on specified LogLevel as follows: 
   
   Log Level	| Enabled Log Types
   -------------+----------------------------------------
   none	        |  set all to false 
   error	    |  error
   warning	    |  error, warning
   info	        |  error, warning, info
   debug	    |  error, warning, info, debug
   entry	    |  error, warning, info, entry, exit, debug
   all	        |  error, warning, info, entry, exit, debug

*/
func setLevel(logLevel LogLevel)

/* return log message as string in format: 
    [LogType] logData;
*/ 
func getLogMessage(logType LogType, logData string) string 

/* write log entry to stdout. 
   Use getLogMessage func to format message
*/ 
func log(logType LogType, logData string)

/* guard function to test if desired logType is enabled */
func isEnabled(logType LogType) bool 

Example;

if isEnabled(LOG_TYPE_DEBUG) { 
    log(LOG_TYPE_DEBUG,"this is a debug message")
}

``` 

# Regarding pre-existing use of klog/log


## Controller uses k8s.io/klog:

klog.go provides functions to set Info, Warning, Error, Fatal messages, plus formatting variants such as Infof.
It also provides V-style logging controlled by the -v and -vmodule=file=2 flags.

Info
Warning
Error
Fatal

By default all log statements write to standard error, but klog provides some flags that modify default behavior

-logtostderr=true
       Logs are written to standard error instead of to files.
-alsologtostderr=false
       Logs are written to standard error as well as to files.
-stderrthreshold=ERROR
       Log events at or above this severity are logged to standard error as well as to files.
-log_dir=""
       Log files will be written to this directory instead of the default temporary directory.

Other flags provide aids to debugging.
-log_backtrace_at=""
       When set to a file and line number holding a logging statement, such as
-log_backtrace_at=gopherflakes.go:234 a stack trace will be written to the Info log whenever execution hits that statement.
           (Unlike with -vmodule, the ".go" must be present.)
-v=0
       Enable V-leveled logging at the specified level.
-vmodule=""
       The syntax of the argument is a comma-separated list of pattern=N, where pattern is a literal file name (minus the ".go" suffix) or
       "glob" pattern and N is a V level. For instance, -vmodule=gopher*=3 sets the V level to 3 in all Go files whose names begin "gopher".

For examples:

klog.Info("Prepare to repel boarders")
klog.Fatalf("Initialization failed: %s", err)
if klog.V(2) {
klog.V(2).Infoln("Processed", nItems, "elements")
}


## Operator uses sigs.k8s.io/controller-runtime/pkg/runtime/log:

log.go contains (imports) following logging packages
         "github.com/go-logr/logr"
         "sigs.k8s.io/controller-runtime/pkg/log/zap"

log.go provides functions Error, Info, StacktraceLevel (record a stack trace for all messages at or above a given level), ...

Error
Info

For examples:

log.Error(err, "unable to reconcile object", "object", object)
log.Info("setting field foo on object", "value", targetValue, "object", object)
log.StacktraceLevel(<stacktracelevel>)
