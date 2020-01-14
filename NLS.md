# Internationalization 

We will translate the following: 

1. Words used by the UI.
1. User-facing words that originate in status or action config maps.

We will not translate the following: 

1. process logs (those are for IBM service use only). 
1. Technical words - especially those that function as part of the API: 
   1. Keys and other API-related words in status or action config maps (e.g. url-action.name is a keyword, not user facing)
   1. Data as stored in Kubernetes resources (e.g. prism.status.value=Normal - the UI will translate 'Normal' but a translated value will not be stored in the resource itself.)

## Words used by the UI

The UI will put all translatable English text in a *_EN.txt (or similarly named, as per prevailing convention) and do a 
lookup to retrieve the correct text value for the user's selected language. 

E.g.

```
ibm.cloud.private=IBM Cloud Private
a11y.editor.escape = You are about to enter a code editor, to escape the editor press control shift q.
annotation = Annotation
expand = Expand
collapse = Collapse
secondaryHeader = secondary header

carbon.table.toolbar.search.label = Filter table
carbon.table.toolbar.search.placeholder = Search

page.title = Application View
page.applicationView.title = Applications
page.componentView.title = Components
page.jobsView.title = Command Actions
page.wasNdCellView.title = WAS ND Cells
page.libertyCollectiveView.title = Liberty Collectives

pagination.itemsPerPage = items per page
pagination.pageRange = {0} of {1} pages
pagination.itemRange = {0}-{1}
pagination.itemRangeDescription = of {0} items

succeeded = Succeeded
running = Running
partiallyRunning = Partially running
failed = Failed
```

The translation team will supply similar files for each supported language - e.g. *_ES.txt for Spanish (or whatever). 

All language files will go into a directory chosen by the UI team and bundled with the UI itself - e.g. nls/prism_EN.txt.  These are included in the bundle downloaded to the browser, so that all translation can be done locally. 

## User-facing words that originate in status config maps, action config maps, or cell/collective status sub-resources 

Examples: 

1. action config map (circa tech preview)

   ```
      {
        "name":"monitor",
        "text":"View AppMetrics Dash",
        "description":"Open AppMetrics Dashboard",
        "url-pattern": "http://${func.kubectlGet(nodes,-l,role=master,-o,jsonpath=${snippet.nodename()})}:${func.kubectlGet(service,${resource.$.metadata.name}-service,--namespace,${resource.$.metadata.namespace},-o,jsonpath=${snippet.nodeport()})}/appmetrics-dash",
        "open-window": "tab"
      }
   ```

   Only text and description require translation. 

2. status config map (circa tech preview)

   Status config maps return the following:
   ```
   { value: <value>, flyover: <detail text> }
   ```

   The \<value\> is a lookup into the values map of this part of the prism.config Configmap:
   ```
   data:
       status-color-mapping: |  
               { "values": { "Normal": "GREEN",   "Warning": "YELLOW",  "Problem": "RED",  "Unknown": "GREY"}, 
                 "colors": { "GREEN":  "#5aa700", "YELLOW":  "#B4B017", "RED": "#A74343", "GREY":"#808080"} 
               }
   ```

   Note: in v1.0, status values are not supported for end user customization.

   Moreover, the UI actually acquires the status value and flyover text - not from the status config maps directly - but rather 
   from the individual application and component resources themselves, in which the status value/flyover data is stored in 
   annotations: 

   - prism.status.value
   - prism.status.flyover
   
3. cell/collective status sub-resources

   The was-nd-cell and liberty-collective resources have a status sub-resource that contains user-facing strings that require translation. Specifically, this is the 'details' field of the status sub-resource - e.g. 
   
   ```
   status:
     cellName: prism-wasnd-dmgrCell01
     details: Connected to prism-wasnd-dmgr.rtp.raleigh.ibm.com:8879 using credentials default/wascell-prism-testcell
     value: ONLINE
   ```
   
### How User-facing words will be translated 

User-facing words that originate in status config maps, action config maps, or cell/collective status sub-resources will be translated by the UI server before they are displayed to the user. This means, specifically: 

1. text and description values from action config maps
1. status value and flyover from resource annotations 
1. details field from status sub-resource of cell/collective resources 

All translatable text for status and actions will be stored in the UI's translation files - e.g. file nls/prism_EN.txt.  

Sample nls/prism_EN.txt content: 

```

# actions by kind, type, and action - e.g. deployment kind,  url type, monitor action 

action.deployment.url.monitor.text = "View AppMetrics Dash"
action.deployment.url.monitor.description = "Open AppMetrics Dashboard" 

# status flyover by kind.<status-value>
status.flyover.deployment.normal = "Desired=%1, Available=%2"
status.flyover.deployment.problem = "Desired=%1, Available=%2"
status.flyover.deployment.warning = "Desired=%1, Available=%2"
status.flyover.deployment.unknown = "Desired=%1, Available=%2"

status.flyover.was-nd-cell.normal = Connected to {0}
status.flyover.was-nd-cell.problem = Not connected to {0}

# details in status sub-resource for cell/collectives
status.details.was-nd-cell.connected = Connected to {0} using credentials {1}
status.details.was-nd-cell.notconnected = Not connected to {0} using credentials {1}

```

### How pre-installed action config maps, status config maps, and cell/collective status sub-resources are written to support internationalization 

In the tech preview, we stored the final text directly in the action and status maps.  With this internationalization support, we will store a key or key plus substitutions as follows: 

<em>For action configuration:</em>

```
      {
        "name":"monitor",
        "text": "View AppMetrics Dash",
        "text.nls":"action.deployment.url.monitor.text"
        "description":"Open AppMetrics Dashboard",
        "description.nls":"action.deployment.url.monitor.description",
        "url-pattern": "http://${func.kubectlGet(nodes,-l,role=master,-o,jsonpath=${snippet.nodename()})}:${func.kubectlGet(service,${resource.$.metadata.name}-service,--namespace,${resource.$.metadata.namespace},-o,jsonpath=${snippet.nodeport()})}/appmetrics-dash",
        "open-window": "tab"
      }
```

So for example, the keys taken from the text and description fields above are: 

1. action.deployment.url.monitor.text
1. action.deployment.url.monitor.description

Used as indices itno the nls/prism_EN.txt (for English) file, they would match these keys: 

1. action.deployment.url.monitor.text = "View AppMetrics Dash"
1. action.deployment.url.monitor.description = "Open AppMetrics Dashboard"

and therefore the effective values of the monitor action's "text" and "description" fields would be: 

1. "View AppMetrics Dash"
1. "Open AppMetrics Dashboard"


<em>For status configuration:</em>

1. status mappings 

   1. In the tech preview, status mappings returned a status value and flyover text. The status value is a key to the prism.config status-color-mapping; the flyover text is just literal text. 

      e.g.  { value: Warning, flyover: "Desired=3, Available=2" }

   1. In v1.0 GA , status mappings will be extended to also include a flyover.nls field, which contains a message key and substitution values. The flyover.nls value is a json array, where element 0 is a translation lookup key and the remaining elements are substitutions.  

      e.g. { value: Warning, flyover: "Desired=3, Available=2", flyover.nls: [ "status.flyover.deployment.normal", "3", "2" ] } 

1. status annotations 

   So in the V1.0 GA, the resource status annotations now contains three lookup keys.  

   E.g. 

   ```
      prism.status.value= Normal
      prism.status.flyover= "Desired=2, Available=2"
      prism.status.flyover.nls= [ "status.flyover.deployment.normal", "3", "2" ]
   ```

   The flyover.nls[0] value is the lookup into nls/prism_EN.txt and remaining array elements substitution values for placeholders {0} and {1} in the following example from that file we have: 

   ```
      status.flyover.deployment.normal = Desired={0}, Available={1}
   ```

   So the value returned by translation would be (in English): 

   ```
     "Desired=2, Available=2"
   ```

The original flyover field is still available as a English language optimization.
 
1. status sub-resource

The status sub-resource for was-nd-cell and liberty-collective resource will include a nls string for the details field:

```
   status:
     cellName: prism-wasnd-dmgrCell01
     details: Connected to prism-wasnd-dmgr.rtp.raleigh.ibm.com:8879 using credentials default/wascell-prism-testcell
     details.nls: [ status.details.was-nd-cell.connected, prism-wasnd-dmgr.rtp.raleigh.ibm.com:8879, default/wascell-prism-testcell ] 
     value: ONLINE
```   

   The details.nls[0] value is the lookup into nls/prism_EN.txt and the remaining array elements are substitution values for placeholders {0} and {1 in the following example from that file we have: 

   ```
      status.details.was-nd-cell.connected = Connected to {0} using credentials {1} 
   ```

   So the value returned by translation would be (in English): 

   ```
      Connected to prism-wasnd-dmgr.rtp.raleigh.ibm.com:8879 using credentials default/wascell-prism-testcell
   ```


### User Overrides and User Defined Kinds (CRDs)

The Prism action configmap hierarchy makes it possible for the user to override pre-installed actions, add additional actions to pre-defined Kinds, and to define actions for user-defined Kinds. Translation is not supported for user supplied actions in release 1.0. Instead, the user will code the user-facing text values directly into the action config maps.  Whatever language in which the user authors the actions is the language displayed on the UI. 

Status configuration mappings are not user customizable in release 1.0.  
