OUTPUT_ARCH( "riscv" )
ENTRY(entry)

MEMORY{
    ROM (rwx) : ORIGIN = 0x00010000, LENGTH = 0x8000 /*32*1024bytes*/
}

SECTIONS
{
  
    PROVIDE(uart_tx = 0x0001000);
    
    .text : {
        . = ALIGN(4);
        *(.text.entry);
        *(.text .text.*);
        . = ALIGN(4);
        PROVIDE(__global_pointer$ = . + 2047);
        *(.rodata .rodata.*);
        . = ALIGN(4);
        *(.data .data.*);
        *(.sdata .sdata.*);

        . = ALIGN(4);
        *(.bss .bss.*);
        *(.sbss .sbss.*);

    } > ROM

    
    PROVIDE(__stack_end = ORIGIN(ROM) + LENGTH(ROM));

}
