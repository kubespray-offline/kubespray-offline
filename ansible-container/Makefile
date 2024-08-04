NAME = kubespray-offline-ansible

PROXY = --build-arg http_proxy=$(http_proxy) --build-arg https_proxy=$(http_proxy)

all: Dockerfile
	podman image build $(PROXY) -t $(NAME) .

rmi:
	podman image rmi $(NAME)

bash:
	podman container run -it --rm $(NAME) /bin/bash

save:  $(NAME).tar.gz

$(NAME).tar.gz:
	podman image save $(NAME):latest | gzip > $(NAME).tar.gz
	chmod 644 $(NAME).tar.gz

clean:
	-/bin/rm $(NAME).tar.gz
