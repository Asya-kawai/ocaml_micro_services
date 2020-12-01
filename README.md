## Create GKE clusters

Login Google Cloud Platform and open Cloud shell.
Input the following command in Cloud shell to create GKE clusters.

* Name: micro-service-demo 
* Node instance type: g1-small
* Node-num per Zone: 1
* Disk-size per node: 10GB
* Zone: us-central1


```
gcloud container clusters create micro-service-demo --preemptible --machine-type g1-small --num-nodes 1 --disk-size 10 --zone us-central1
```

### Note: How to delete clusters?

Input the following command in Cloud shell to delete GKE clusters.

```
gcloud container clusters delete micro-service-demo --zone us-central1
```

