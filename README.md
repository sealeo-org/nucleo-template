# Nucleo-template

## Descritpion
This repository contains required tools to compile for nucleo devices with GCC ARM

## Usage
### Project creation
You can simply clone the repository, then run:
```bash
tools/clone $name
```
where $name is the name of your project to create (its path will be ../$name). It is possible to specify an absolute path (including the name).

In case of update, run
```bash
git pull
tools/update $name
```

(you can replace `tools/update` by `tools/full-update` if the changes are big, but you will lose your user-defined Makefile)

### Compilation by docker
Link, or copy, the file `tools/dmake` to somewhere that is in your $PATH

Then, you can simply replace any call to `make` like that:
```bash
dmake
```

# Features
## Compatible devices

* F303K8
* F401RE

## Makefile

* Compilation (obviously) for specific target, displaying informations like memory usage
* Upload (auto mount/unmount if run by the docker) (`make upload`)

## Docker

* Isolation of the toolchain (GCC ARM): no dependencies, ...
* Up-to-date compilers (docker Archlinux)
