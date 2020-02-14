# Appsody Integration

## Email Exchange about this topic 

Chris Bailey sent this email: 

```
To: Christopher Vignola/Poughkeepsie/IBM@IBMUS, Arthur De Magalhaes/Toronto/IBM@IBMCA
From: Chris Bailey/UK/IBM
Date: 09/17/2019 08:25AM
Subject: Enhanced App Annotations

Hi Chris:
 
As part of the next phase of work on Appsody and Kabanero, we're looking to enhance the visibility that our Todd person has of what is deployed into in Kubernetes clusters. To do this, we're looking at adding a much wider set of annotations on the deployed application CRs, covering things like:
 
Git Repo and Git Commit that contains the source for the microservice
Configured and used versions of the Appsody Stack / Kabanero Collection for the microservice build
etc
We're also looking at going potentially further and including things like:
Manifest of the modules and versions used in the app
OpenAPI spec (if any) for the application
etc
What I'd like to get your thoughts on is whether there's a naming convention it might make sense for us to follow for the annotations, and how much of this is makes sense for us to surface up through AppNav.
 
Regards,

C (Chris) Bailey 
STSM, IBM Runtimes for Java, Node.js and Swift,
IBM Cloud Development,
```

Chris Vignola replied: 

```
Re: Enhanced App Annotations
Christopher Vignola
 	
Tuesday, September 17, 2019 01:21PM
To:	Chris Bailey
Cc:	Arthur De Magalhaes, Michael C Thompson, Patrick G Nyeste

Chris,

kAppNav defines a number of annotations and labels in the form:  domain.subdomain.identifier.   Specifically, it uses kappnav.app.* 

I think a straight-forward name-space-like separation makes sense for appsody and other things - e.g. appsody.repo.* ,  appsody.stack.*, etc 

I think it would make sense for appnav to provide a first class experience for these data.  In the earliest appnav wireframes I was depicting information from the dev ops pipeline.  In my earliest thinking, I was imaging access back to the dev ops pipeline logs would be useful, answering many questions like the ones the annotations you propose can answer.  

I'm imagining various ways in the appnav UI,  where a user can view a set of annotations for a given component.   I'm interested in discussing this further.  I'll followup with a strawman UI mock up to show you a starter idea.  We can go from there. 

Chris Vignola
STSM - IBM Cloud Pak for Applications 
phone: 1+845-978-2363
email: cvignola@us.ibm.com
http://chris.vignola.googlepages.com
```

## Design Proposal

We could support multiple dynamic sections in the kAppNav component view page.  Each dynamic section could display 
registered annotation values, specified on the component resource.  

Example: 

1. Register annotation pattern 'appsody.**' (done via kappnav config).
1. Create deployment resource  (e.g. loyalty-level Deployment) as part of application with various appsody.** annotations specified on it.
1. kAppNav displays an expandable section, that when expanded, show all annotations that match pattern 'appsody.**'

![prism](https://github.com/kappnav/design/blob/master/images/kappnav-ui-comp-ext.1.png)

![prism](https://github.com/kappnav/design/blob/master/images/kappnav-ui-comp-ext.2.png)
