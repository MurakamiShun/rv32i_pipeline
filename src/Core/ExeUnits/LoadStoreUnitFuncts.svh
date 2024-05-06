`ifndef LOAD_STORE_UNIT_FUNCTS_SVH
`define LOAD_STORE_UNIT_FUNCTS_SVH

/* verilator lint_off DECLFILENAME */
package LoadStoreUnitFuncts;
    typedef enum logic[2:0] {
        LD  = 3'b000,
        LDU = 3'b001,
        ST  = 3'b010,
        FENCE = 3'b101,
        FENCEI = 3'b111,
        Unknown = 3'b110
    } Type;
endpackage

package LoadStoreUnitBytes;
    typedef enum logic[1:0] {
        BYTE = 2'b00,
        HALF = 2'b01,
        WORD = 2'b10,

        Unknown = 2'b11
    } Type;
endpackage

`endif