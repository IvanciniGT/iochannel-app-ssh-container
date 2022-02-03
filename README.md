# iochannel/ssh-container

Contenedor basado en ubuntu con un servidor ssh y git instalados y configurados.

## Uso

### Ejecutar las pruebas:

```bash
$ cd tests 
$ ./execute.sh
```
### Generar la imagen:

```bash
$ ./build.sh
```

### Solicitando generación de claves

```bash
$ docker run --rm -v $PWD/keys:/generatedKeys \
             --name ssh-test iochannel/ssh-container:latest
```

### Suministrando la clave
   
```bash
   $ docker run --rm -v $PWD/keys/public:/publicKey \
                --name ssh-test iochannel/ssh-container:latest
```

### Para acceder al contenedor via ssh

```bash
   $ ssh -i keys/publica alumno@172.17.0.2
   $ ssh -i keys/publica -o StrictHostKeyChecking=no \
         -l "alumno" "172.17.0.2"
```
