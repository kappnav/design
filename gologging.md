# About Golang Logging

A new function package will be created to manage logging in App Navigator Golang components, of which there are presently two: 

1. Controller
1. Operator  

# Golang Logging Function

```
type LogLevel int
/* LogLevel values of LogLevel 
   LogLevel is what user requests 
*/
const ( 
        LogLevelNone  LogLevel = 0  
        LogLevelWarning LogLevel = 1
        LogLevelError LogLevel = 2
        LogLevelInfo LogLevel = 3
        LogLevelDebug LogLevel = 4
        LogLevelEntry LogLevel = 5
	LogLevelAll LogLevel = 6
)

type LogType int 
/* LogType values of LogType 
   LogType is how code categorizes log message
*/
const (
        LogTypeEntry LogType = 0  
        LogTypeExit LogType = 1
        LogTypeInfo LogType = 2
        LogTypeWarning LogType = 3
        LogTypeError LogType = 4   
        LogTypeDebug LogType = 5
)

/*Logger interfaces*/
type Logger interface {
        SetLogLevel(logLevel LogLevel)       
        Log(callerName string, logType LogType, logData string)
        IsEnabled(logType LogType) bool
}

/*NewLogger create new Logger*/ 
func NewLogger(enableJSON bool) Logger {}

type loggerImpl struct {
   /*global variable holds current log level*/
	LogLevel LogLevel
   /*global variable to hold current log type enablement flags*/ 
	LogTypeEnabled [6]bool 
   /*flag to enable JSON log*/
        enableJSONLog bool
}

/*Log write log entry to stdout. Log in JSON format when enableJSONLog is set, otherwise, log in plain text 
   Use getLogMessage func to format message 
*/ 
func (logger *loggerImpl) Log(goFileName string, funcName string, logType LogType, logData string) 

/*IsEnabled guard function to test if desired logType is enabled */
func (logger *loggerImpl) IsEnabled(logType LogType) bool 

/*getLogMessage return log message as string in format: 
    [timestamp + LogType + callerName ] + logData
*/ 
func (logger *loggerImpl) getLogMessage(logType LogType, logData string) string 

/*setLogTypes set log types */
func (logger *loggerImpl) setLogTypes(value bool) {}


/*SetLogLevel set global log level to specified value 
   set IsEnabled based on specified LogLevel as follows: 
   
   Log Level	 | Enabled Log Types
   -------------+----------------------------------------
   none	         |  set all to false 
   error	 |  error
   warning	 |  error, warning
   info	         |  error, warning, info
   debug	 |  error, warning, info, debug
   entry	 |  error, warning, info, entry, exit, debug
   all	         |  error, warning, info, entry, exit, debug
*/
func (logger *loggerImpl) SetLogLevel(logLevel LogLevel) 
     

Example;

if (logger.IsEnabled(LogTypeDebug)) {
   logger.Log(callerName(), LogTypeDebug, "this is a debug message")
}  
   
Stdout in plain text:
[2020-04-07T17:19:53Z INFO controller.go:1221 parseResourceBasic] apiVersion: v1

Stdout in JSON format:
{"level":"info","ts":1586277250.0874062,"logger":"controller_kappnav","caller":"kappnav_controller.go:128 add","msg":"Watch for changes to primary resource"}

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
