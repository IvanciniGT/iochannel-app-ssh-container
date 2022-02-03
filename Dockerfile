################################################################
# USO
################################################################
# Solicitando generación de claves
#   $ docker run --rm -v $PWD/keys:/generatedKeys \
#                --name ssh-test iochannel/ssh-container:latest
#
# Suministrando la clave
#   $ docker run --rm -v $PWD/keys/public:/publicKey \
#                --name ssh-test iochannel/ssh-container:latest
#
# Para acceder al contenedor via ssh
#   $ ssh -i keys/publica alumno@172.17.0.2
#   $ ssh -i keys/publica -o StrictHostKeyChecking=no \
#         -l "alumno" "172.17.0.2"
################################################################

FROM ubuntu:20.04

################################################################
# INSTALACION DE SOFTWARE
################################################################
# Istalar el software requerdo
RUN apt update
# Instalar servicio de ssh
RUN apt install openssh-server -y
# Instalar sudo
RUN apt install sudo -y
# Instalar git
RUN apt install git -y
# Instalar man-db
RUN apt install man-db -y

################################################################
# CONFIGURACION DE SSH
################################################################
# Crear clave pricada para el contenedor
RUN ssh-keygen -A
# Añadir configuración propia de ssh :
#  - quitar los mensajes de bienvenida
#  - desactivar las conexiones via password
COPY resources/sshd_config /etc/ssh/sshd_config
# Desactivar ejecución de motd (más mensajes al hacer login)
RUN chmod -x /etc/update-motd.d/*
# Crear carpeta para albergar el pid de sshd
RUN mkdir /run/sshd \
 && chmod 0755 /run/sshd

################################################################
# CREACION DEL USUARIO QUE CONECTARA MEDIANTE SSH
################################################################
# El usuario se llama alumno, con grupo alumno
# No tiene contraseña
RUN groupadd -g 999 alumno && useradd -u 999 -g alumno -G sudo -m -s /bin/bash alumno
# Se añade a los sudoers
# Se desactiva de los suoders la necesidad de escribir el password
RUN sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "alumno ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER alumno
# Creamos la carpeta de trabajo
RUN mkdir -p /home/alumno/environment

################################################################
# CONFIGURACIONES SSH DEL USUARIO
################################################################
# Creación de carpeta para configuraciones de ssh
RUN mkdir -p ~/.ssh
# Eliminación del mensaje de ssh
RUN mkdir -p ~/.cache/ && > ~/.cache/motd.legal-displayed

################################################################
# CONFIGURACION DE SU SHELL: BASH
################################################################
# Añadimos fichero propio bash_profile
COPY resources/bash_profile /home/alumno/.bash_profile
# Autocompletado de la bash
RUN cd /tmp \
 && wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
 && mv git-completion.bash /home/alumno/.git-completion.bash

################################################################
# COMANDO DE ARRANQUE DEL CONTENEDOR
################################################################
COPY resources/init.sh /init.sh
RUN sudo chmod 0755 /init.sh
CMD ["/bin/bash", "-c", "/init.sh"]

################################################################
# VOLUMENES PARA LAS CLAVES
################################################################
# Archivo para que opcionalmente se suministra la clave publica 
# con la que conectarse y que debe registrarse
RUN sudo touch /publicKey \
 && sudo chmod 0744 /publicKey
# Carpeta para las claves generadas si no pasan una publica
RUN sudo mkdir /generatedKeys \
 && sudo chmod 0777 /generatedKeys
# Notificar los volumenes que pueden usarse
VOLUME [/generatedKeys]
VOLUME [/publicKey]

################################################################
# VARIABLES DE ENTORNO
################################################################
# Nombre del alumno para registrar en git
ENV USER_NAME="Alumno de IOChannel"
# Email del alumno para registrar en git
ENV USER_EMAIL="alumno@iochannel.tech"

################################################################
# OTRAS CONFIGURACIONES
################################################################
WORKDIR /home/alumno/environment
EXPOSE 22
LABEL maintainer="Ivan Osuna Ayuste <ivan@iochannel.tech>"
################################################################

RUN sudo apt autoclean

