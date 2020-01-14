# kAppNav and App Navigator Projects

kAppNav is the open source project.  App Navigator is the commercialization of kAppNav, and includes additional features.

**Integration Environment**

| AppNav v1.0.1 | ICP Console |
|:--------------|:------------|
| [https://9.37.201.239:8443/appnav/](https://9.37.201.239:8443/appnav/) (u/p=admin/icp4u) | [https://9.37.201.239:8443/console/dashboard](https://9.37.201.239:8443/console/dashboard) |

<table> 

<tr>
<th>Public Content</th>
<th>Internal Repos</th>
</tr>

<tr> 
<td>

<table>
 
<tr>
<th>Open Source</th>
<th>Helm Chart</th>
<th>Knowledge Center</th>
<th>DTE Lab</th>
</tr>

<tr> 

<td>

[github.com](https://github.com/kappnav)

</td>

<td>

[v1.0.0](https://github.com/IBM/charts/tree/master/stable/ibm-app-navigator) 

</td>
<td>

[v1.0.0](https://www.ibm.com/support/knowledgecenter/en/SSAW57_9.0.5/com.ibm.websphere.nd.multiplatform.doc/ae/tcld_appnav.html)

</td>

<td>

[v1.0.0](https://cloudcontent.mybluemix.net/cloud/garage/dte/tutorial/application-navigator-introduction)

</td>

</tr>
</table>


<td>

<table>
 
<tr>
<th>Helm Chart</th>
<th>Source Code</th>
</tr>

<tr> 
<td>

[helm-chart-prism](https://github.ibm.com/WASCloudPrivate/helm-chart-prism)

</td>
<td>

[prism](https://github.ibm.com/WASCloudPrivate/prism)

</td>
</tr>

</table>

</td>

</tr>

</table>


## Project Overview 

Want the big picture?  Read the [overview](https://github.com/kappnav/design/blob/master/a.overview.md).

## Setup Instructions for OKD and Minishift 

1. Use [vlaunch](https://vlaunch.rtp.raleigh.ibm.com/signin) to allocate a VM 
1. [single VM OKD](https://ibm.box.com/s/lfmpeu0994z0h7y89upbd2orytm4eewj)
1. [multi VM OKD](https://ibm.box.com/s/dm3v316lrxs6bdrxnnizo2kdhn1addgt)
1. [minishift](https://docs.okd.io/latest/minishift/getting-started/installing.html)

Other setup instructions: 

1. [Elastic Search, FluentD, Kibana (EFK) (use this one before the official kabanero.io/guides link)](https://github.com/fwji/openshift-logging)
1. [Application Monitoring on OK with Prometheus and Grafana (use this one before the official kabanero.io/guides link)](https://github.com/fwji/openshift-monitoring)

## How to run various things: 

1. [Access openapi/ui on Openshift](https://github.com/kappnav/design/blob/master/api-server-openapi-ui.md)
1. [Run UI & API server locally](https://github.com/kappnav/ui/wiki/UI-Development:-Getting-started#step-two-start-api-server)


## Project Resources  

1. [kAppNav and App Navigator Releases](https://github.com/kappnav/design/blob/master/releases.md)
1. [Development Process](https://github.com/kappnav/design/blob/master/dev-process.md)
1. [Release Procedures](https://github.com/kappnav/design/blob/master/release-procedures.md)
1. [App-centric box folder](https://ibm.ent.box.com/folder/46276533612)
1. [Prism Aha - features](https://bigblue.aha.io/products/ICPRIVATE/feature_cards#)
1. [Prism Roadmap Git Issues](https://github.ibm.com/WASCloudPrivate/roadmap#boards?repos=210627,211371,210628,210626&showPRs=false)
1. [Prism source code (Github)](https://github.ibm.com/WASCloudPrivate/prism)
1. [Prism chart source code (Github)](https://github.ibm.com/WASCloudPrivate/helm-chart-prism)
1. [Prism Tech Preview Helm Chart](https://github.com/WASdev/app-nav-helm-chart)
1. [Prism SPbD Folder](https://ibm.box.com/s/so610crq25tk5imv2s5vice4fs33ukli)
1. [COO Scans](https://github.com/kappnav/design/blob/master/coo-scans.md)
1. [QCert Guidelines](https://ibm.box.com/s/77qudm1by56xcc6uluf2wtvzie3nl6cx)
1. [QCert Analysis](https://ibm.box.com/s/u7d1hqnxkoph76d1wjr28cpkc2gvl43f)

## Prism Proposal and Prototype  

1. [Original concept deck](https://ibm.box.com/s/efeyea5h3bqq3esg41qn0s92x45pzzek)
1. [Prototype github](https://github.ibm.com/seed/prism)
1. Running (usually) [(aging) prototype](http://9.42.75.88:31378/) demonstrating stocktrader and [bookinfo application](https://istio.io/docs/examples/bookinfo/) 
1. [Prism screen shots (from prototype)](https://ibm.box.com/s/1v5l78wi1rdrgvkw326g353nlnkk8pbc)
1. [MCM Playback](https://ibm.ent.box.com/file/315284621261)

## Design Resources 
1. [ICP Console design guide](https://pages.github.ibm.com/IBMPrivateCloud/design/Standards/)
1. [ICP Console source code](https://github.ibm.com/IBMPrivateCloud/platform-ui)
1. [Prism will use Carbon Design Components](http://www.carbondesignsystem.com/)
   1. [Carbon Design Components for React (used in prototype)](https://github.com/IBM/carbon-components-react)
   1. [Carbon Design Components for Vanilla JavaScript](https://github.com/IBM/carbon-components)
1. Kubernetes [Application SIG](https://github.com/kubernetes-sigs/application)
1. IBM Cloud Pak [Playbook](https://playbook.cloudpaklab.ibm.com/)
   1. [Values Metadata guide](http://icp-content-playbook.rch.stglabs.ibm.com/values-metadata/)
   
# Application Navigator Design 

## Prism Design v1.0.0
1. [Feature Overview](https://github.com/kappnav/design/blob/master/feature-overview.md)
1. [Use Cases](https://github.com/kappnav/design/blob/master/use-cases.md)
1. [Defining Applications](https://github.com/kappnav/design/blob/master/defining-apps.md)
1. [Architecture](https://github.com/kappnav/design/blob/master/architecture.md)
1. [Shared Services](https://github.com/kappnav/design/blob/master/shared-services.md)
1. [Handling Dependencies](https://github.com/kappnav/design/blob/master/dependencies.md)
1. [APIs](https://github.com/kappnav/design/blob/master/APIs.md)
1. [Custom Resources](https://github.com/kappnav/design/blob/master/custom-resources.md)
1. [Application Status](https://github.com/kappnav/design/blob/master/status-determination.md)
1. [Annotations](https://github.com/kappnav/design/blob/master/annotations.md)
1. [Actions](https://github.com/kappnav/design/blob/master/actions-config-maps.md)
1. [UI](https://github.com/kappnav/design/blob/master/UI-layout.md)
   1. [Command Action UI](https://github.com/kappnav/design/blob/master/command-action-ui.md)
   1. [WAS ND Cell UI](https://github.com/kappnav/design/blob/master/was-cell-ui.md)
   1. [Liberty Collective UI](https://github.com/kappnav/design/blob/master/liberty-collective-ui.md)
1. [Install](https://github.com/kappnav/design/blob/master/install.md)
1. [Security](https://github.com/kappnav/design/blob/master/security.md)
1. [Internationalization](https://github.com/kappnav/design/blob/master/NLS.md)
1. [Auto-App Support](https://github.com/kappnav/design/blob/master/auto-app-lifecycle.md)
1. [Cloud Pak Support](https://github.com/kappnav/design/blob/master/auto-app-lifecycle.md#cloud-pak-support)
1. [Namespace Support](https://github.com/kappnav/design/blob/master/namespaces.md)

## Design for Kabanero

1. [KUBE_ENV Environment Variable](https://github.com/kappnav/design/blob/master/kubeEnv-Env-var.md)
1. [Helm Operator](https://github.com/kappnav/design/blob/master/helm-operator.md)
1. [OKD Console Integration](https://github.com/kappnav/design/blob/master/okd-console-integration.md)
1. [Supported platforms](https://github.ibm.com/WASCloudTribe/design/blob/master/platforms.md#kappnav)

## Design for IBM Application Navigator 2.0.0

1. [Image names](https://ibm.box.com/s/6526zggnrqfpqpbfbokdj32t8oti5w3z)
1. [Supported platforms](https://github.ibm.com/WASCloudTribe/design/blob/master/platforms.md#ibm-application-navigator-v200)

## Design for IBM Application Navigator 2.0.1

1. [Action Enablement](https://github.com/kappnav/design/blob/master/action-enablement.md)
1. [Detail Sections](https://github.com/kappnav/design/blob/master/ui-detail-sections.md)
1. [Support for Appsody](https://github.com/kappnav/design/blob/master/appsody.md)

## Design {k}AppNav 0.5.0

1. [Group-Version-Resource (GVR)](https://github.com/kappnav/design/blob/master/groups-and-versions.md)

## Design {k}AppNav 0.6.0 

1. [KindActionMapping Custom Resource Definition](https://github.com/kappnav/design/blob/master/kind-action-mapping.md)
1. [Logging](https://github.com/kappnav/design/blob/master/logging.md)

## List of known issues

1. If you have issue starting minishift on your laptop/mac with error "403 API rate limit exceeded”. 
   Here is the work around for that issue:      https://github.com/minishift/minishift/blob/master/docs/source/troubleshooting/troubleshooting-getting-started.adoc
   
## Some good How to
1. [How to view completed job's log and get file from the container where the Job ran](https://github.com/kappnav/design/blob/master/completedJob.md)


