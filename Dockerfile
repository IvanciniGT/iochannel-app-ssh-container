
FROM ubuntu:20.04

################################################################
# ARGUMENTOS PARA LA GENERACION DE LA IMAGEN
################################################################
ARG USER_NAME=alumno
# Nombre del alumno para registrar en git
ARG GIT_USER_NAME="Alumno de IOChannel"
# Email del alumno para registrar en git
ARG GIT_USER_EMAIL="alumno@iochannel.tech"

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
# El usuario se llama $USER_NAME, con grupo $USER_NAME
# No tiene contraseña
RUN groupadd -g 999 $USER_NAME && useradd -u 999 -g $USER_NAME -G sudo -m -s /bin/bash $USER_NAME
# Se añade a los sudoers
# Se desactiva de los suoders la necesidad de escribir el password
RUN sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER $USER_NAME
# Creamos la carpeta de trabajo
RUN mkdir -p /home/$USER_NAME/environment

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
COPY resources/bash_profile /home/$USER_NAME/.bash_profile
# Autocompletado de la bash
RUN cd /tmp \
 && wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
 && mv git-completion.bash /home/$USER_NAME/.git-completion.bash

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
 && sudo chmod 0777 /publicKey
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
ENV GIT_USER_NAME=$USER_NAME
# Email del alumno para registrar en git
ENV GIT_USER_EMAIL=$USER_EMAIL

################################################################
# OTRAS CONFIGURACIONES
################################################################
WORKDIR /home/$USER_NAME/environment
EXPOSE 22
LABEL maintainer="Ivan Osuna Ayuste <ivan@iochannel.tech>"
################################################################

RUN sudo apt autoclean

