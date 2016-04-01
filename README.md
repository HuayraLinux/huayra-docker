# huayra-docker

Contenedor de Docker para la creacion de paquetes para Huayra.
Esto es un **Work In Progress** y esta publicado `AS IS`, por lo que probablemente falle y no nos hacemos cargo :-)

## Como lo utilizo?

	$ git clone https://github.com/HuayraLinux/huayra-docker
	$ cd huayra-docker
	$ docker build -t huayra-docker .

	$ docker run -ti --rm huayra-docker
	% build pkg-holahuayra

	$ docker run -ti --rm huayra-docker sh -c "build pkg-holahuayra"

