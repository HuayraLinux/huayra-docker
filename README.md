# huayra-docker

Contenedor de Docker para la creacion de paquetes para Huayra.
Esto es un **Work In Progress** y esta publicado `AS IS`, por lo que probablemente falle y no nos hacemos cargo :-)

## Como lo utilizo?

	$ git clone https://github.com/HuayraLinux/huayra-docker
	$ cd huayra-docker
	$ docker build -t huayra-docker .

	$ docker run -ti --rm --privileged huayra-docker
	% build pkg-holahuayra

	$ docker run -ti --rm --privileged huayra-docker sh -c "build pkg-holahuayra"


Note: El flag [`--privileged`](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) es necesario porque que al ejecutar `pbuilder` va a necesitar acceso a ciertos `devices` y Docker por defecto no brinda esos permisos.  
Quizas lo mas prolijo sea utilizar `--devices` y listar los necesarios pero mientras tanto, `--privileged`.
