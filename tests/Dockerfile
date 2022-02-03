FROM ubuntu:20.04

RUN apt update
RUN apt install openssh-client -y

CMD ls -l /keys && ssh -i /keys/privateKey -o StrictHostKeyChecking=no -l $USER $SSH_SERVER

VOLUME [/keys]

ENV USER=""
ENV SSH_SERVER=""
