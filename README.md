## Table of Contents

-   [Installing project using a Scratch Org](#installing-project-using-a-scratch-org)
-   [FAQ](#faq)
-   [Showcase clip](#showcase)
-   [My own thoughts](#my-own-thoughts)

## Installing project using a Scratch Org

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:

    - Enable Dev Hub in your Trailhead Playground
    - Install Salesforce CLI
    - Install Visual Studio Code
    - Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension

1. Authenticate with your hub org and add an alias of your choice:

    ```
    sfdx auth:web:login -d -a huborgalias
    ```

1. Clone this repository:

    ```
    git clone https://github.com/mynameismateusz/assignmentKPN
    cd assignmentKPN
    ```

1. Create a scratch org and provide it with an alias (**orgAlias**):

    ```
    sfdx force:org:create -s -f config/project-scratch-def.json -a orgAlias
    ```

1. Push source to your scratch org:

    ```
    sfdx force:source:push
    ```

1. Import sample data:

    ```
    sfdx force:data:tree:import -p ./importTestData/testDataPlan.json
    sfdx force:apex:execute -f ./importTestData/postImport.apex
    ```
    Alternatively:
    ```
    sfdx force:data:tree:import -u [username] -p ./importTestData/testDataPlan.json
    sfdx force:apex:execute -u [username] -f ./importTestData/postImport.apex
    ```

1. Open the scratch org:

    ```
    sfdx force:org:open
    ```

1. In **Setup**, navigate to **Lightning App Builder** and click edit next to **Order Record Page**

1. Activate it as an Org Default

1. Have fun! :)

## Showcase

<img src="img/Showcase.gif">

Download the showcase clip [here](https://user-images.githubusercontent.com/80535755/111089419-1908e280-852c-11eb-938a-3015b3ed51d2.mov)

#### Empty lists
<img width="1329" alt="EmptyList" src="https://user-images.githubusercontent.com/80535755/111089434-2c1bb280-852c-11eb-8758-958c926c85d3.png">


## FAQ

1. If you want to verify Order Confirmation requests, you can do it [here](https://godis-orders.requestcatcher.com/).

1. What's **GODIS**? It's the name of the imaginary Order Confirmation system. Godis means 'Candy' in Swedish!
<img src="https://user-images.githubusercontent.com/80535755/111089447-39d13800-852c-11eb-8a1b-5327ac7c9084.png" width="350" title="Swedish Fish Candy">


## My own thoughts

#### Relation field used in lightning-datatable

As it is described [here](https://trailblazer.salesforce.com/ideaView?id=0873A000000lLXYQA2), lightning-datatable does not support relation fields. I wanted to display OrderItem name from Product2.Name, but it wouldn't have worked. So I was considering the following:
* Creating an Apex Class with @AuraEnable fields to serve as a wrapper, where I could flatten the Product2.Name. It would have worked, but I wasn't super convinced.
* Simply create a formula field. Easy, but I was like - meh.
* Iterating over the collection in js and assigning the Product2.Name to Name. It's not too bad, but it's also not very performant and it requires making a deep copy of the array because data returned from Apex is immutable. It isn't ideal, but I also don't expect too many items to be pulled from SF at a single time, because of the lazy loading, so I decided to go with it.

#### Using Apex for queries

The requirement is to use Apex for DML and data querying. While I understand that it's done this way, so there's actually a chance to show off Apex skills, I decided to use native getRecord() function to fetch Order. There's is one big benefit of doing it this way and it's the fact, that if user changes the Order Status in the standard detail edit page, the components will notice it and update accordingly.

#### SObject Selectors

While I think that using fflib in such a small project would be an overkill - I still wanted to separate SOQL from the service business logic.


