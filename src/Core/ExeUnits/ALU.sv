`include "../RV32Consts.svh"
`include "ALUFuncts.svh"

module ALU(
    input RV32Consts::IntReg op1,
    input RV32Consts::IntReg op2,
    input ALUFuncts::Type funct,
    output RV32Consts::IntReg result
);

import RV32Consts::*;

logic[63:0] signed_mul;
logic[63:0] unsigned_mul;
logic[63:0] signed_unsigned_mul;
always_comb begin
    signed_mul = $signed(op1) * $signed(op2);
    unsigned_mul = op1 * op2;
    signed_unsigned_mul = $signed(op1) * op2;
end

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

        ALUFuncts::MUL    : result = signed_mul[31:0];
        ALUFuncts::MULH   : result = signed_mul[63:32];
        ALUFuncts::MULHSU : result = signed_unsigned_mul[63:32];
        ALUFuncts::MULHU  : result = unsigned_mul[63:32];

        // ALUFuncts::DIV  : result = $signed(op1) / $signed(op2);
        // ALUFuncts::DIVU : result = op1 / op2;
        // ALUFuncts::REM  : result = $signed(op1) % $signed(op2);
        // ALUFuncts::REMU : result = op1 % op2;
        default: result = 0;
    endcase
end
endmodule
