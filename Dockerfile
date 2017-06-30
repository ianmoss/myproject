# Staged build to copy in HRIS libs securely.
# For information on local debugging and updating these libs,
# see the sample-container readme file.
FROM alpine
RUN apk update && apk add openssh-client git
COPY .ssh /root/.ssh
RUN chmod 600 /root/.ssh/*
RUN ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts
RUN GIT_SSH_COMMAND="ssh -i /root/.ssh/hris-r-lib" git clone git@github.com:tesera/hris-r-lib.git /var/lib/hris-r-lib
RUN git --git-dir /var/lib/hris-r-lib/.git reset --hard 86b8d02
RUN GIT_SSH_COMMAND="ssh -i /root/.ssh/hris-python-lib" git clone git@github.com:tesera/hris-python-lib.git /var/lib/hris-python-lib
RUN git --git-dir /var/lib/hris-python-lib/.git reset --hard 24bbadf

# Start with rbase
FROM python:2.7
RUN apt-get update --fix-missing

# Install Python Dependencies
RUN pip install numpy


# Install HRIS Dependencies
COPY --from=0 /var/lib/hris-python-lib /var/lib/hris-python-lib

# Setup some ENV vars
ENV PATH="/root/my-process:${PATH}"
ENV HRIS_PYTHON_LIB="/var/lib/hris-python-lib"
ENV HRIS_DATA="/data"

# Install project files
RUN mkdir -p /root/my-process/
COPY my_process.py /root/my-process


# Finally, set the container entrypoint
ENTRYPOINT ["my_process.py"]
