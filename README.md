# huayra-docker

Contenedor de Docker para la creacion de paquetes para Huayra.
Esto es un **Work In Progress** y esta publicado `AS IS`, por lo que probablemente falle y no nos hacemos cargo :-)

## Como lo utilizo?

	$ git clone https://github.com/HuayraLinux/huayra-docker
	$ cd huayra-docker
	$ docker build -t huayra-docker .
        [...]
	$ docker run -ti --rm --privileged huayra-docker
	% hpkg pkg-holahuayra clone build
	$ docker cp fancy_name:/pkg/result/ .


Note: El flag [`--privileged`](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) es necesario porque que al ejecutar `pbuilder` va a necesitar acceso a ciertos `devices` y Docker por defecto no brinda esos permisos.  
Quizas lo mas prolijo sea utilizar `--devices` y listar los necesarios pero mientras tanto, `--privileged`.

## Faltan los chroot!

Es cierto, decidi no agregarlos ya que pesaban demasiado (?).  
De todas formas, es posible recrearlos de la siguiente manera:

	for ARCH in amd64 i386;
	do
		sudo pbuilder create --basetgz huayra-torbellino-$ARCH.tgz --distribution jessie --debootstrapopts --arch --debootstrapopts $ARCH --mirror ftp://ftp.debian.org/debian;
	done

Una vez creados, ingresamos al chroot y utilizamos al flag `--save-after-login` para guardar los cambios que realicemos:

	sudo pbuilder login --save-after-login --basetgz huayra-torbellino-amd64.tgz

Finalmente estando dentro del `chroot` agregamos los repositorios al archivo `/etc/apt/sources.list`, salimos y eso es todo.
