## Command Action View UI Page

## Target User Experience for Command Initiation 

When a user selects a command action from a Prism action menu, they should experience the following: 

1. If action has required input defined, a popup window will appear soliciting user input.  This window has an OK and Cancel button.  If the user clicks Cancel, the window closes and the action is canceled (i.e. does not take place).  If the user clicks the OK button, the input is validated and the command is initiated.  If the input is not valid, an error message is displayed and the user remains on the input window.  

1. If the no input is required, the command is immediately iniated.  The command is initiated by invoking the [Command Action Execution API](https://github.com/kappnav/design/blob/master/APIs.md#command-action-execution-api).

1. When a command is initiated, a pop up window is displayed informing the user the requested action has been initiated.  This window should include a link to the Command Action View (see below):  i.e. 'Click __here__ to review command action results.' Clicking on the link should take the user to the Comman Action View, with the most recently initiated command displayed in the first row of the table (this could be done by sorting newest to oldest).  

Command actions initiated by a Prism user run asynchronously as Kubernetes jobs.  Their execution and completion can be tracked and viewed in the Prism Command Action View, which is launched from the [Prism global menu](https://github.com/kappnav/design/blob/master/UI-layout.md#prism-global-menu): 

![action-view](https://github.com/kappnav/design/blob/master/images/actions-view.png)

**Note** The command actions displayed are filtered to show only command actions initiated by the current Prism user. 

### Implementation note concerning validation

The UI should do what static validation it can by ensuring a required field has a value and issuing a generic error message if not.

**Fields**

1. Status

   Shows the current status of the action job as follows: 

   1. Green/Running
   1. Green/Succeeded
   1. Red/Failed
 
1. Action

   Specifies name of command action.  This is the 'text' value from the cmd-action specification.  This is a hot spot field that links to the 'detail' action for this resource kind.  

1. Application

   Specifies the namespace/name of the application that is the object of this command action.

1. Component

   Specifies the namespace/name of the component that is the object of this command action.

1. Age

   Specifies the age (in days) of the command action.

1. Action

   Specifies available actions that can be performed against the command action.  Delete is the only supported action.  
   
   
   
## Command Action Specification

Example: 

```


    cmd-actions: 
      [
        {  
          "name": "Trace", 
          "text": "Toggle Trace", 
          "description": "Turn trace on or off.", 
          "image": "appnav-twas-utilities:v1",
          "cmd-pattern": "toggleTrace.sh ${resource.$.metadata.name}", 
          "input-popup": { "label": "Enter trace string", "default": "com.ibm.*=all" } 
          "requires-input": "tracestring"
           "menu-item": "true" 
        }
      ]

    inputs: | 
       {
          "tracestring": {  
             "title": "Specify Trace String", 
             "fields": [ 
                { "name": "tracestring", "type" : "string", "description": "Trace String", "default": "com.ibm.*=all",     
                  optional=false } 
             ],
             "validator": "tracestring-validator" 
          },  
       }

   snippets: | 
       {
          "tracestring-validator": "function tracestringValidator(value) { 
                                       if ( value != undefined ) 
                                          return  { "valid": true | false, "message": ""}
                                       else
                                          return   { "valid": false, "message": "Trace string is required!"}
                                    }"
       } 
```
------------------------------------------------------------------------------------------------------------------------------
