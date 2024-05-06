
void main(void);

__attribute__((naked, section(".text.entry")))
void entry(void){
    __asm__ volatile(
        ".option push;"
        ".option norelax;" // optimized out prevention
        "la gp, __global_pointer$;"
        "la sp, __stack_end;"
        ".option pop;"
        :
        :
        :
    );
    main();
    __asm__ volatile(
        "ebreak;"
        :
        :
        :
    );
}