## influx-cluster-losing-data

When running an influx cluster influx seems to lose some data when the cluster is restarted. Previously created databases can not be found. Recreating the database and inserting some new data brings back the old data.

### Steps to reproduce
Check out this repository, then run `run.sh`.
```
$ git clone git@github.com:scarhand/influx-cluster-losing-data.git
$ cd influx-cluster-losing-data
$ ./run.sh
```

The run.sh script will build a container with influx 0.10 installed from apt. It will then create a cluster of 3 influx nodes. Two of them are data and meta nodes and the third is a meta node. 
When the cluster is started, a database (mydb) will be created and some data will be inserted into it.

The script will then sleep for 2 minutes before restarting the cluster. After the cluster has restarted it will run a `SHOW DATABASES` query.
This will show that the database we created earlier does not exist.

It will then create the database again and run a SELECT query. The result of this query will also be empty.

It will then insert some new data in the database and run a SELECT query again. The result of this query will show the new data *and* the old data.
The datapoint with a timestamp in 2015 will be gone. Only 'recent' data is kept.


### Other scripts
- stop.sh Stops the cluster
- build.sh Builds the influx container
- clear-data.sh Removes the mounted data directories
- run_containers.sh Will start the cluster