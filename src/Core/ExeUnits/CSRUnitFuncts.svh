`ifndef CSR_UNIT_FUNCTS_SVH
`define CSR_UNIT_FUNCTS_SVH

package CSRUnitFuncts;
    typedef enum logic[3:0] {
        ECallEBreak = 'b00,
        ReadWrite   = 'b01,
        ReadSet     = 'b10,
        ReadClear   = 'b11
    } Type;
endpackage

`endif