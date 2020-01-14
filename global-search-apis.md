# Design Notes for Global Search APIs

Model URI:
1. /kappnav/search
1. /kappnav/search/resources/{resource-kind}
1. /kappnav/search/resources/{resource-kind}?key1=value1&&key2=value2||key3[lt]value3||key4[gt]value4

Note:
1. Operators supported for the key and value pair as operands are:
    1. &&
    2. ||

1. Operators supported with the key and value as operands are::
    1. =
    2. !=
    3. [lt]
    4. [gt]

For example, with "component" resource, the url path is:
1. /kappnav/search/resources/components?key1=value1&&key2=value2||key3[lt]value3||key4\[gt]value4
1. /kappnav/search/resources/applications?key1=value1&&key2=value2||key3[lt]value3||key4\[gt]value4

