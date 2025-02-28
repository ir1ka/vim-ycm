# vim with YCM plugin container image

The image 

## run the container

``` shell
# Create and run in background
./run.sh
# Start a bash to use vim
./enter.sh
```

## build image

``` shell
PUSER=$(id -un) PUID=$(id -u) WORKDIR=$HOME./build.sh
```
