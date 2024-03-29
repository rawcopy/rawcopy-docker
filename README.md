# rawcopy-docker
http://rawcopy.org

https://hub.docker.com/r/rawcopy/rawcopy


Run Rawcopy using Docker with the following command:
``` 
docker run  -v "Path to .CEL-files":/input:ro \
            -v "Path to output":/output \
            -u `id -u`:`id -g` \
            rawcopy/rawcopy:1.1 \
            2
```
Or with singularity:
```
singularity run --bind "Path to .CEL-files":/input \
                --bind "Path to output":/output \
                docker://rawcopy/rawcopy:1.1 \
                2
```

1. The first -v/bind is the path to the .CEL-files directory
1. The second -v/bind is the path to the output directory
1. The number at the end specifies the number of cores to use
