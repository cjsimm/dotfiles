FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	sudo \
	curl \
	file \
	git \
	vim \
	zsh \
	build-essential \
	&& rm -rf /var/lib/apt/lists/*

# Create a non-root dev user
RUN useradd -ms /bin/bash devuser && \
	echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER devuser
WORKDIR /home/devuser

CMD ["/bin/bash"]
