# PaperMC Update Bash

PaperMC update script written in Bash

## Requirement
* jq

## How to use
```
$ ./update.sh -v VERSION -f -o OUTPUT
```

## Options
> -v VERSION: Minecraft version

> -f : Enable force download

> -o OUTPUT: Output file name (Default is paper.jar)

## Example
Download latest 1.19.2 version PaperMC
```
./update.sh -v 1.19.2
```

Download latest 1.19 version PaperMC as 1_19.jar
```
./update.sh -v 1.19 -o 1_19.jar
```

