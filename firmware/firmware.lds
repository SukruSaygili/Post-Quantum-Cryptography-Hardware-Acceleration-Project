ENTRY(start)

MEMORY 
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K   
    RAM (rwx) : ORIGIN = 0x00014000, LENGTH = 256K
}

SECTIONS {
    /* IMEM: Code and initialization (Gaat naar firmware_imem.coe) */
    .text : {
        . = ALIGN(4);
        *(.init);
        *(.text*);
        . = ALIGN(4);
    } > ROM

    /* DMEM: Read-only data (constants, strings).  */
    .rodata : {
        . = ALIGN(4);
        *(.rodata*);
        *(.srodata*);
        . = ALIGN(4);
    } > RAM 

    /* DMEM: Initialized variables (Gaat naar firmware_dmem.coe samen met rodata) */
    .data : {
        . = ALIGN(4);
        *(.data*);
        *(.sdata*);
        . = ALIGN(4);
    } > RAM

    /* DMEM: Uninitialized variables (Zeroed out) */
    .bss : {
        . = ALIGN(4);
        __bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } > RAM

    /* Set the Stack Pointer to the very top of RAM */
    /* 0x00014000 + 448K (0x70000) = 0x00084000 */
    __stack_top = ORIGIN(RAM) + LENGTH(RAM);
    

    /DISCARD/ :
    {
        *(.note*);
        *(.iplt*);
        *(.igot*);
        *(.rel*);
        *(.comment);
        *(.riscv.attributes);
    }
}