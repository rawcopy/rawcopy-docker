# rawcopy-docker

Run Rawcopy with the following command:
``` 
docker run  -v "Path to .CEL-files":/input:ro \
            -v "Path to output":/output \
            rawcopy:1.1 \
            2
```

The first -v is the path to the .CEL-files directory
The second -v is the path to the output directory
The number at the and specifies the number of cores to use
