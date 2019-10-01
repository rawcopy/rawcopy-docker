# ____
#|  _ \ __ ___      _____ ___  _ __  _   _
#| |_) / _` \ \ /\ / / __/ _ \| '_ \| | | |
#|  _ < (_| |\ V  V / (_| (_) | |_) | |_| |
#|_| \_\__,_| \_/\_/ \___\___/| .__/ \__, |
#                             |_|    |___/
# Created by Björn Viklund and Martin Dahlö 
# Contact: bjorn.viklund@uppmax.uu.se
# http://www.rawcopy.org
FROM ubuntu:18.04 as base

RUN mkdir /workdir
WORKDIR /workdir

# Set better mirrors
RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list       && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt bionic-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt update; apt install -y wget --no-install-recommends

# Preload Rawcopy
RUN wget http://array.medsci.uu.se/R/src/contrib/rawcopy_1.1.tar.gz

# Set timezone to avoid install questions
ENV TZ=Europe/Stockholm
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install R
RUN apt update; apt upgrade -y
RUN apt update; apt install -y r-base-core=3.4.4-1ubuntu1 

# Create directories
RUN mkdir /input /output
RUN mkdir -p /workdir/R/x86_64-pc-linux-gnu-library/3.4 /workdir/.Rcache

# Create Rscript dependencie file
RUN echo    '.libPaths(c("/workdir/R/x86_64-pc-linux-gnu-library/3.4", "/usr/local/lib/R/site-library", "/usr/lib/R/site-library", "/usr/lib/R/library")) \n \
            source("http://bioconductor.org/biocLite.R") \n \
            biocLite("affxparser",ask=F) \n \ 
            biocLite("DNAcopy",ask=F) \n \
            biocLite("aroma.light",ask=F) \n \
            install.packages(c("foreach","doMC","PSCBS","squash","digest","ape","SDMTools")) \n \
            install.packages("rawcopy_1.1.tar.gz",repos=NULL,type="source")' > /workdir/install.packages.R

# Install Rscripts from the Rscript file
RUN Rscript /workdir/install.packages.R

# Remove rawcopy_1.1.tar.gz
RUN rm /workdir/rawcopy_1.1.tar.gz

# Create Rawcopy scriptfile
RUN echo    '.libPaths(c("/workdir/R/x86_64-pc-linux-gnu-library/3.4", "/usr/local/lib/R/site-library", "/usr/lib/R/site-library", "/usr/lib/R/library")) \n \
            library(rawcopy) \n \
            args = commandArgs(trailingOnly=TRUE) \n \
            if (length(args)==0) { \n \
                cores=1 \n \
            } else if (length(args)==1) { \n \
                cores = args[1] \n \
            } \n \
            rawcopy(CELfiles.or.directory="/input",outdir="/output",cores=cores)' > /workdir/run.rawcopy.R

# Change permissions to make it possible to run the container as a host user
RUN chmod 777 /output

# Run Rawcopy
ENTRYPOINT ["Rscript", "--no-save", "/workdir/run.rawcopy.R"]
