NAME = kubespray-offline-ansible

PROXY = --build-arg http_proxy=$(http_proxy) --build-arg https_proxy=$(http_proxy)

all: Dockerfile
	docker image build $(PROXY) -t $(NAME) .

rmi:
	docker image rmi $(NAME)

bash:
	docker container run -it --rm $(NAME) /bin/bash

save:  $(NAME).tar.gz

$(NAME).tar.gz:
	docker image save $(NAME):latest | gzip > $(NAME).tar.gz
	chmod 644 $(NAME).tar.gz

clean:
	-/bin/rm $(NAME).tar.gz
