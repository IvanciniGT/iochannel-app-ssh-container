export IMAGE_VERSION=$(cat version)
echo Construyendo imagen y ejecutando pruebas
cd tests
./execute.sh
[[ $? == 0 ]] && docker-compose build --no-cache \
              && docker tag $(docker images -q iochannel/ssh-container:test-${IMAGE_VERSION}) iochannel/ssh-container:version-${IMAGE_VERSION} \
              && docker tag $(docker images -q iochannel/ssh-container:test-${IMAGE_VERSION}) iochannel/ssh-container:latest \
              && docker rmi iochannel/ssh-container:test-${IMAGE_VERSION} \
              && docker image prune -f \
              && echo "Imagen generada" \
              && exit 1

echo "Error al generar la imagen"              
exit 1