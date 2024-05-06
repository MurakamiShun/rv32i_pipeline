`include "../RV32Consts.svh"
`include "BranchUnitFuncts.svh"

module BranchUnit(
    input logic en,
    input RV32Consts::IntReg op1,
    input RV32Consts::IntReg op2,
    input BranchUnitFuncts::Type funct,
    output logic token
);
import BranchUnitFuncts::*;

always_comb begin
    if(en)begin
        unique case(funct)
            BEQ  : token = op1 == op2;
            BNE  : token = op1 != op2;
            BLT  : token = $signed(op1) < $signed(op2);
            BLTU : token = op1 < op2;
            BGE  : token = $signed(op1) >= $signed(op2);
            BGEU : token = op1 >= op2;
            JAL  : token = 1;
            JALR : token = 1;
            default : token = 0;
        endcase
    end else begin
        token = 0;
    end
end
endmodule