# Kind Action Mapping (KAM) Auto Creation

When an opeator installing its config maps and kams before an application navigator is installed, the kam cannot be created as 
Application Navigator is not installed, therefore, no KAM CRD is available yet. With the KAM auto creation, when Application 
Navigator will create the kams automatically.

## Embeded KAM in Action Config Map
Application Navigator will auto-create/delete a kam resource when a specially labeled onfig map is created. 
