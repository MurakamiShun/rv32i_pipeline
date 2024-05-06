`ifndef CSR_UNIT_FUNCTS_SVH
`define CSR_UNIT_FUNCTS_SVH

package CSRUnitFuncts;
    typedef enum logic[1:0] {
        ECallEBreak = 2'b00,
        ReadWrite   = 2'b01,
        ReadSet     = 2'b10,
        ReadClear   = 2'b11
    } Type;
endpackage

`endif