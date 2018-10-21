# druid-docker

## Docker for setting up single machine Druid Cluster

[Install Docker](https://docs.docker.com/install/)

Download and launch the docker image

```sh
docker pull abhi195/druid-cluster
docker run --rm -i -p 9001:9001 -p 8090:8090 -p 8083:8083  -p 8082:8082 -p 8081:8081 abhi195/druid-cluster
```

Getting the cluster up may take some time, wait for few minutes.

## Web interfaces for the cluster

- Supervisor status : http://localhost:9001

- Druid Coordinator Console : http://localhost:8081/#/

- Druid Overlord Console : http://localhost:8090/console.html

## Build Druid Docker Image

To build the docker image yourself

```sh
git clone https://github.com/abhi195/druid-docker.git
docker build -t druid-cluster druid-docker
```

## Logging

Supervisor logs are configured at `/var/log/druid/`

Druid's are at its default path.

For seeing the logs you need to login into the container:
- List running containers using `docker ps`
- Note container-id of container running druid-cluster
- Execute `docker exec -it container-id /bin/bash`
- For more info on logging into container look at [docker exec](https://docs.docker.com/engine/reference/commandline/exec/)

## Troubleshooting

Latest image `abhi195/druid-cluster` is tested on OSX with 4GB of RAM and 2CPSs assigned to Docker.

### XX:MaxDirectMemorySize error when using OSX

If you are running docker on OSX, you might get XX:MaxDirectMemorySize error because on OSX the Docker environment runs within [HyperKit](https://github.com/docker/hyperkit) hypervisor.

Driud configurations inside `conf` folder already includes some changes in properties to fix this error.

To fix this you can take following steps:
- Tweak memory/cache/processing/threads related properties 
- Increase the CPUs and RAM allocated to the Docker running on you machine
