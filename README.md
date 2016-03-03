Installation
Using nucleo-template:
* install Docker
* docker build -t nucleo .
* tools/clone NAME # this will create a project in the parent directory

Should you want to use OpenOCD:
* wget http://ufpr.dl.sourceforge.net/project/openocd/openocd/0.9.0/openocd-0.9.0.tar.bz2 -Oopenocd-0.9.0.tar.bz2
* tar jxf openocd-0.9.0.tar.bz2
* cd openocd-0.9.0
* ./configure --enable-ftdi --enable-stlink && make && sudo make install

See tools directory

Update
Updating nucleo-template is done by:
git pull

You can choose the branch you want to track, but you should keep working on master

After an update, you should execute:
* for minor update: tools/update [ProjectName...]
* for major update: tools/full-update [ProjectName...]

The update tool is safe and will only update mbed libraries and sub makefiles
You can pass multiple project names to update all at once

The full-update tool is a bit more aggressive, it will update all makefiles and
try to remove old files that are now unnecessary.
It is advised to make a backup before calling it (by git stash, for exemple, or a simple copy)
