`include "../RV32Consts.svh"
`include "ALUFuncts.svh"

module ALU(
    input RV32Consts::IntReg op1,
    input RV32Consts::IntReg op2,
    input ALUFuncts::Type funct,
    output RV32Consts::IntReg result
);

import RV32Consts::*;

always_comb begin
    unique case(funct)
        ALUFuncts::ADD  : result = op1 + op2;
        ALUFuncts::SUB  : result = op1 - op2;
        ALUFuncts::SLT  : result = { {(XLEN-1){1'b0}}, $signed(op1) < $signed(op2)};
        ALUFuncts::SLTU : result = { {(XLEN-1){1'b0}}, op1 < op2};
        ALUFuncts::AND  : result = op1 & op2;
        ALUFuncts::OR   : result = op1 | op2;
        ALUFuncts::XOR  : result = op1 ^ op2;
        ALUFuncts::SLL  : result = op1 << op2[4:0];
        ALUFuncts::SRL  : result = op1 >> op2[4:0];
        ALUFuncts::SRA  : result = $signed(op1) >>> op2[4:0];
        default: result = 0;
    endcase
end
endmodule
