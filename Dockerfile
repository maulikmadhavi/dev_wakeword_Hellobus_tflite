# set a base image
FROM tensorflow/tensorflow:1.15.0

# Get some utils
RUN apt-get update \
    && apt-get install -qqy screen vim lsof net-tools\
    && rm -rf /var/lib/apt/lists

# set the woking directory in the container
WORKDIR /project

# Copy entire project in working dir
COPY src .

CMD ["./project/run.sh"]
