#!/bin/bash

export IMAGE_VERSION=$(cat ../version)

docker-compose build --no-cache
docker-compose down -v > /dev/null 2>&1
docker-compose up -d

INTENTOS=0
MAXIMOS_INTENTOS=5
SALIDA=2
MENSAJE="Test fallido"
echo
echo Esperando el resultado de la prueba
echo
while (( $INTENTOS < $MAXIMOS_INTENTOS )) && [[ "$(docker inspect ssh_container_test --format='{{.State.Status}}')" != "exited" ]]; do
    sleep 2
    echo Intento: $INTENTOS
    let INTENTOS++;
done

echo Resultado de la prueba $(docker inspect ssh_container_test --format='{{.State.Status}}'): $(docker inspect ssh_container_test --format='{{.State.ExitCode}}') 2> /dev/null


RESULTADO=$(docker inspect ssh_container_test --format='{{.State.ExitCode}}' 2> /dev/null) 
[[ "$RESULTADO" == 0 ]] && SALIDA=0 && MENSAJE="Test satisfactorio"
[[ -n "$RESULTADO" && "$RESULTADO" != 0 ]] && SALIDA=1

docker-compose down -v > /dev/null 2>&1

echo $MENSAJE

docker rmi iochannel/ssh-container:test-${IMAGE_VERSION}
docker rmi iochannel/ssh-container-test:latest
docker image prune -f 

exit $SALIDA