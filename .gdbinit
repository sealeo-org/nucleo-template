set auto-load safe-path /
set history save on
set confirm off
shell sudo openocd -f /usr/share/openocd/scripts/board/st_nucleo_f401re.cfg&
target remote localhost:3333
monitor reset init

define reset
    monitor reset halt
    monitor reset run
    monitor reset halt
    monitor reset run
end

define flash
    monitor reset halt
    monitor flash write_image erase "$arg0.hex"
    monitor sleep 200
    monitor reset halt
    file $arg0.elf
    reset
end

define build
    make
    flash nucleo
end

define exit
    monitor shutdown
    quit
end
