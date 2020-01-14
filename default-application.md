## Default Application Resource


Each Kubernetes resource created by a cloud pak,  should specify the project name as a label value and include an application resource with a label selector that selects the labeled resources. 

More details to come ... 

------------------------------------------------------------------------------------------------------------------------------
Arthur De Magalhaes [12:40 PM]
hey Chris.  awesome, thanks!   I definitely agree this is needed.
Would we need a toggle that says "create a new App definition vs join an existing App definition"?

Christopher Vignola [12:43 PM]
Yes.  We'll need to think about how to present the option.
If joining you want to omit the application resource.
There's another case where you want to omit the application resource, too.
That case is where the user is deploying something they do not regard as an application at all - e.g. something they regard as a piece of infrastructure.
So conceptually, there are 3 choices.  The implementation is actually binary, though - either create an application resource or don't.
