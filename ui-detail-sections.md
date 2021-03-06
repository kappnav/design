# UI Detail Sections

UI Detail Sections provides a way to 1) define and 2) display a section of detailed data for any resource kind.  A UI Detail section is comprised of two principle things:

1. a section name 
1. a section datasource 
1. a section layout 

A named section displays data from a defined datasource using a specified layout.  Sections can exist in a hierarchy.  In a section hierarchy, it is possible for a named section to override another section of the same name. 

## Specification

Section: 

```
name: 
title: 
title.nls:
description:
description.nls: 
datasource:
layout:
enablement-label: 
```

| field | definition | 
|-------|------------|
| name  | Specifies name of section. This is the section's identity. This it not intended as user facing data.  |
| title | Specifies section title. This is user facing data. | 
| title.nls | Specifies NLS lookup key for translated text based on locale. |
| description | Provides user facing description. Can be used in end-user tools, such as UI for flyover text. | 
| description.nls | Specifies NLS lookup key for translated text based on locale. |
| datasource | Specifies name of datasource, which describes where the data comes from for this section. This name must match a corresponding datasource definition. |
| layout | Specifies name of layout definition, which gives hints to end-user tools, such as UI, for how to display the data. This field is optional. |
| enablement-label | Specifies the name of the label that must be specified in the target resource in order to activate this section for that resource. | 

Note: layout will not be implemented to start with;  it will be added in the future. There is a default for each datasource type - see next section for more on that. 

----------------

Datasource: 

A datasource is applied against a target resource to produce a result set of values to populate a detail section. 

```
name: 
type:
< type-specific fields >
```

| field | definition | 
|-------|------------|
| name  | Specifies name of datasource. |
| type  | Specifies the type of datasource. | 
| < type-specific fields > | These fields vary based on datasource type. |

Note: "annotations" is the first datasource type to be implemented;  others (e.g. "metrics") will be added in the future. 

------------------------

Datasources, once "queried' produce a result set of this form: 

      { 
           "name": "<datasource name>", 
           "type": "<datasource type>",
           < type-specific fields >
      }

| field | definition | 
|-------|------------|
| name  | Specifies name of datasource. |
| type  | Specifies the type of datasource. | 
| < type-specific fields > | These fields vary based on datasource type. |

---------------------

Datasource Type: "labels-annotations"

Purpose: returns selected labels and/or annotations from the target resource. 

Supports these < type-specific fields > : 

| field | definition | 
|-------|------------|
| label-prefixes  | Specifies an array of label prefixes. |
| labels | Specifies an array of label names. |
| annotation-prefixes  | Specifies an array of annotation prefixes. |
| annotations | Specifies an array of annotation names. | 

Semantics: 

The labels-prefixes field specifies a list of label name prefixes. Labels on the target resource that start with any of the specified prefixes are selected for return as the data for this datasource. The labels field specifies an array of labels by name to be returned as the data for this datasource.  Both label-prefixes and labels fields can be specified together.  If a label is selected by both the labels-prefixes and labels specifications,  that label is returned only once.

The annotations-prefixes field specifies a list of annotation name prefixes. Annotations on the target resource that start with any of the specified prefixes are selected for return as the data for this datasource. The annotations field specifies an array of annotations by name to be returned as the data for this datasource.  Both annotations-prefixes and annotations fields can be specified together.  If an annotation is selected by both the annotations-prefixes and annotations specifications,  that annotation is returned only once. 

The "annotations" datasource type is paired with the builtin layout, named "tabular", as it's default layout. The tabular layout displays annotations and their values in a table format, with annotation names in the first column and annotation values in the second column.

---------------------------

The "labels-annotations" datasource produces this format result set: 

```
      { 
           "name": "<datasource name>", 
           "type": "labels-annotations",
           "data": [  { "label": "<label name>", "value": "<annotation value>" }, ... , 
                      { "annotation": "<annotation name>", "value": "<annotation value>" }, ... ]
      }
```

| field | definition | 
|-------|------------|
| name  | Specifies name of datasource. |
| type  | Specifies the type of datasource - "labels-annotations" |
| data  | Specifies an array of label/value and/or annotation/value objects produced by the datasource |

## Configuration

Sections and datasources are defined in a ConfigMap. They are stored as an array of stringified JSON.  The ConfigMap is named according to the target resource kind.  Format follows: 

```
kind: ConfigMap
name: kappnav.sections.<kind>
data: 
   sections: | 
       [ { 
           "name": "<section name>", 
           "title": "<section title>",
           "title.nls": "<section title NLS lookup key>",
           "description": "<description text>",
           "description.nls": "<description text NLS lookup key>",
           "datasource": "<datasource name>",
           "enablement-label": "<label name>"
         }
       ]
   section-datasources: | 
       [ { 
           "name": "<datasource name>", 
           "type": "<datasource type>",
           < type-specific fields >
         }
       ]
``` 

## API Support

The following APIs will be updated to return information about sections: 

1. GET applications
1. GET application (one application)
1. GET components 

Two new arrays will be returned as a peer to the "actions" array for each application and component: 

1. sections array 
1. section-data array 

The sections array returns section definitions for each section activated (see enablement-label, in earlier section above) for the target resource. The section-data array returns data to be displayed in each activated section. 

E.g. 

```
"components": [ 
   { 
      "component": { ... },
      "action-map": 
      {
           "url-actions": [ { ... }, ... ],
           "cmd-actions": [ { ... }, ... ]
      } 
      "section-map": 
      {
           "sections": [ { section-def-1 }, ... ], 
           "section-data": [ { section-data-1 }, ... ]
      }
   }
]

```

Notes: 

1. If there are no enabled sections, the section-map field will be returned as "section-map": {}
1. The sections array is a array of section definitions. Their structure is the same as how they appear in the kappnav-config ConfigMap.
1. The sections-data array is an array of objects with this structure: 

```
      { 
           "name": "<datasource name>", 
           "type": "<datasource type>",
           < type-specific fields >
      }

```

## UI Support 

The UI will be updated to display an indicator for any application or component that has activated sections.  E.g. 

![design-closed](https://github.com/kappnav/design/blob/master/images/design-closed.jpg)

![design-open](https://github.com/kappnav/design/blob/master/images/design-open.jpg)

## Example 

Example Configuration:

```
kind: ConfigMap
name: kappnav-config
data: 
   sections: | 
       [ { 
           "name": "appsody", 
           "title": "Appsody Information",
           "title.nls": "section.appsody.title",
           "description": "Information about this resource injected by Appsody technology during development and deployment."
           "description.nls": "section.appsody.description", 
           "datasource": "appsody-labels-annotations",
           "enablement-label": "stack.appsody.dev/id"
         }
       ]
   section-datasources: | 
       [ { 
           "name": "appsody-labels-annotations", 
           "type": "labels-annotations",
           "label-prefixes": [ "image.opencontainers.org", "stack.appsody.dev" ],
           "annotation-prefixes": [ "image.opencontainers.org","stack.appsody.dev","source.image.appsody.dev" ],
           "labels": [ "app.appsody.dev/name" ],
           "annotations": []
         }
       ]
``` 

-----------------
Example Resource: 

```
apiVersion: appsody.dev/v1beta1
kind: AppsodyApplication
metadata:
  name: payment-service # .appsody-config.yaml project-name
  labels: # max len 63 chars, must be empty or begin and end with [a-z0-9A-Z] and may contain dashes (-), underscores (_), dots (.)
    image.opencontainers.org/title: payment-service
    image.opencontainers.org/version: 1.0.3
    image.opencontainers.org/licenses: Apache-2.0
    stack.appsody.dev/id: nodejs-express
    stack.appsody.dev/version: 0.2.7
    app.appsody.dev/name: mobile-card
  annotations:
    image.opencontainers.org/description: Payment microservice for the mobile app
    image.opencontainers.org/authors: Kyle Christianson <christik@us.ibm.com>
    image.opencontainers.org/url: https://github.com/kylegc/appsody-project
    image.opencontainers.org/documentation: https://github.com/kylegc/appsody-project
    image.opencontainers.org/source: https://github.com/kylegc/appsody-project/tree/master
    image.opencontainers.org/revision: e5917a6debe2442b73066a32af1dd3e3928ff429-modified
    image.opencontainers.org/created: 2019-10-22T10:41:36-05:00
    stack.appsody.dev/title: Node.js Express
    stack.appsody.dev/configured: appsody/nodejs-express:0.2
    stack.appsody.dev/tag: appsody/nodejs-express:0.2.7
    stack.appsody.dev/description: Express web framework for Node.js
    stack.appsody.dev/authors: Chris Bailey <cnbailey@gmail.com>, Neeraj Laad <neeraj.laad@gmail.com>
    stack.appsody.dev/url: https://github.com/appsody/stacks/tree/master/incubator/nodejs-express
    stack.appsody.dev/documentation: https://github.com/appsody/stacks/tree/master/incubator/nodejs-express/README
    stack.appsody.dev/source: https://github.com/appsody/stacks/tree/master/incubator/nodejs-express/image
    stack.appsody.dev/revision: a3917a6debe2442b73066a32af1dd3e3928fg874
    stack.appsody.dev/created: 2019-10-07T10:11:51+0000
    source.image.appsody.dev/committer: Kyle Christianson <christik@us.ibm.com>
    source.image.appsody.dev/author: Kyle Christianson <christik@us.ibm.com>
    source.image.appsody.dev/date: Mon Oct 28 14:38:33 2019 +0000
    source.image.appsody.dev/message: The last commit message
    source.image.appsody.dev/contextDir:
```

-------------------
Example API Result: 

```
"components": [ 
   { 
      "component": { 
          "metadata": {
          "name": "payment-service",
          "namespace": "mobile-card",
          "annotations": 
          ...
      }
      "action-map": 
      {
           "url-actions": [
           {
            "name": "replicas",
            "text": "View Replicas",
            ...
           } 
      } 
      "section-map":
      {
           "sections": [
             { 
               "name": "appsody", 
               "title": "Appsody Information",
               "title.nls": "section.appsody.title",
               "description": "Information about this resource injected by Appsody technology during development and deployment."
               "description.nls": "section.appsody.description", 
               "datasource": "appsody-annotations",
               "enablement-label": "stack.appsody.dev/id"
             }
           ], 
           "section-data": [ 
             {
               "name": "appsody",
               "data": [
                   {"label": "image.opencontainers.org/title", "value": "payment-service"},
                   {"label": "image.opencontainers.org/version", "value": "1.0.3"},
                   {"label": "image.opencontainers.org/licenses", "value": "Apache-2.0"},
                   {"label": "stack.appsody.dev/id", "value": "nodejs-express"},
                   {"label": "stack.appsody.dev/version", "value": "0.2.7"},
                   {"label": "app.appsody.dev/name", "value": "mobile-card"},
                   {"annotation": "image.opencontainers.org/description", "value": "Payment microservice for the mobile app"},
                   {"annotation": "image.opencontainers.org/authors", "value": "Kyle Christianson <christik@us.ibm.com>"},
                   {"annotation": "image.opencontainers.org/url", "value": "https://github.com/kylegc/appsody-project"},
                   {"annotation": "image.opencontainers.org/documentation", "value": "https://github.com/kylegc/appsody-project"},
                   {"annotation": "image.opencontainers.org/source", "value": "https://github.com/kylegc/appsody-project/tree/master"},
                   {"annotation": "image.opencontainers.org/revision", "value": "e5917a6debe2442b73066a32af1dd3e3928ff429-modified"},
                   {"annotation": "image.opencontainers.org/created", "value": "2019-10-22T10:41:36-05:00"},
                   {"annotation": "stack.appsody.dev/title", "value": "Node.js Express"},
                   {"annotation": "stack.appsody.dev/configured", "value": "appsody/nodejs-express:0.2"},
                   {"annotation": "stack.appsody.dev/tag", "value": "appsody/nodejs-express:0.2.7"},
                   {"annotation": "stack.appsody.dev/description", "value": "Express web framework for Node.js"},
                   {"annotation": "stack.appsody.dev/authors", "value": "Chris Bailey <cnbailey@gmail.com>, Neeraj Laad <neeraj.laad@gmail.com>"},
                   {"annotation": "stack.appsody.dev/url", "value": "https://github.com/appsody/stacks/tree/master/incubator/nodejs-express"},
                   {"annotation": "stack.appsody.dev/documentation", "value": "https://github.com/appsody/stacks/tree/master/incubator/nodejs-express/README"},
                   {"annotation": "stack.appsody.dev/source", "value": "https://github.com/appsody/stacks/tree/master/incubator/nodejs-express/image"},
                   {"annotation": "stack.appsody.dev/revision", "value": "a3917a6debe2442b73066a32af1dd3e3928fg874"},
                   {"annotation": "stack.appsody.dev/created", "value": "2019-10-07T10:11:51+0000"},
                   {"annotation": "source.image.appsody.dev/committer", "value": "Kyle Christianson <christik@us.ibm.com>"},
                   {"annotation": "source.image.appsody.dev/author", "value": "Kyle Christianson <christik@us.ibm.com>"},
                   {"annotation": "source.image.appsody.dev/date", "value": "Mon Oct 28 14:38:33 2019 +0000"},
                   {"annotation": "source.image.appsody.dev/message", "value": "The last commit message"},
                   {"annotation": "source.image.appsody.dev/contextDir", "value": ""}
               ]
             }
           ]
      }
   }
]
```
