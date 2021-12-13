FROM ethereum/client-go:v1.9.13

WORKDIR /app
ADD . /app

VOLUME "/data"
ENTRYPOINT "/app/entrypoint.sh"
EXPOSE 8178 8546
EXPOSE 8545 8545