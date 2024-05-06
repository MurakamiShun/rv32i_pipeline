riscv64-unknown-elf-gcc -O2 -march=rv32izicsr -mabi=ilp32 -ffreestanding -nostartfiles -mcmodel=medany -static -Ibarebones -I. \
 core_list_join.c core_main.c core_matrix.c core_state.c core_util.c barebones/core_portme.c barebones/ee_printf.c barebones/cvt.c barebones/start.c -o coremark.elf -T barebones/link.ld
riscv64-unknown-elf-objdump -D coremark.elf > coremark.dump
riscv64-unknown-elf-objcopy -O binary -j .text -x coremark.elf coremark_inst.bin
od -An -tx4 -w4 -v coremark_inst.bin > coremark_inst.hex