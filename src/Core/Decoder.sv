`include "Instruction.svh"
`include "MicroCode.svh"

module Decoder(
    input Instruction inst,
    input logic[31:0] pc,
    output MicroCode micro_code
);

enum logic[3:0] {
    RType      = 0,
    IType      = 1,
    ITypeShift = 2,
    SType      = 3,
    BType      = 4,
    UType      = 5,
    JType      = 6,
    CSRType    = 7,
    FenceType  = 8,
    IllegalType= 9
} inst_type;

localparam type(micro_code.alu) alu_disable = '{
    funct : ALUFuncts::Unknown,
    op1_src : OP1Src::RS1,
    op2_src : OP2Src::RS2,
    en : 0
};

// depend on opcode
always_comb begin
    unique case(inst.common.opcode)
        7'b01101_11 : begin // LUI
            inst_type = UType;
            micro_code.rd_src = RdSrc::ALU;
            micro_code.alu = '{
                funct : ALUFuncts::ADD,
                op1_src : OP1Src::ZERO,
                op2_src : OP2Src::IMM,
                en : 1
            };
            micro_code.ld_st_en = 0;
            micro_code.br_en = 0;
            micro_code.csr_en = 0;
            micro_code.imm_adder_src = 'x;
            micro_code.funct = 'x;
            micro_code.jump_en = 0;
        end
        7'b00101_11 : begin // AUIPC
            inst_type = UType;
            micro_code.rd_src = RdSrc::ALU;
            micro_code.alu = '{
                funct : ALUFuncts::ADD,
                op1_src : OP1Src::PC,
                op2_src : OP2Src::IMM,
                en : 1
            };
            micro_code.ld_st_en = 0;
            micro_code.br_en = 0;
            micro_code.csr_en = 0;
            micro_code.imm_adder_src = 'x;
            micro_code.funct = 'x;
            micro_code.jump_en = 0;
        end
        7'b11011_11 : begin // JAL
            inst_type = JType;
            micro_code.rd_src = RdSrc::PC4;
            micro_code.jump_en = 1;
            micro_code.imm_adder_src = ImmAdderSrc::PC;
            micro_code.alu = alu_disable;
            micro_code.br_en = 0;
            micro_code.funct = 'x;
            micro_code.ld_st_en = 0;
            micro_code.csr_en = 0;
        end
        7'b11001_11 : begin // JALR
            inst_type = IType;
            micro_code.rd_src = RdSrc::PC4;
            micro_code.jump_en = 1;
            micro_code.imm_adder_src = ImmAdderSrc::RS1;
            micro_code.alu = alu_disable;
            micro_code.br_en = 0;
            micro_code.funct = 'x;
            micro_code.ld_st_en = 0;
            micro_code.csr_en = 0;
        end
        7'b11000_11 : begin // Branch
            inst_type = BType;
            micro_code.rd_src = RdSrc::NotUsed;
            micro_code.alu = alu_disable;
            micro_code.br_en = 1;
            micro_code.imm_adder_src = ImmAdderSrc::PC;
            unique case(inst.Itype.funct3)
                3'b000 : micro_code.funct.br = BranchUnitFuncts::BEQ;
                3'b001 : micro_code.funct.br = BranchUnitFuncts::BNE;
                3'b100 : micro_code.funct.br = BranchUnitFuncts::BLT;
                3'b101 : micro_code.funct.br = BranchUnitFuncts::BGE;
                3'b110 : micro_code.funct.br = BranchUnitFuncts::BLTU;
                3'b111 : micro_code.funct.br = BranchUnitFuncts::BGEU;
                default: micro_code.funct.br = BranchUnitFuncts::Unknown;
            endcase
            micro_code.ld_st_en = 0;
            micro_code.csr_en = 0;
            micro_code.jump_en = 0;
        end
        7'b00000_11 : begin // Load
            inst_type = IType;
            micro_code.rd_src = RdSrc::LD;
            micro_code.alu = alu_disable;
            micro_code.imm_adder_src = ImmAdderSrc::RS1;
            unique case(inst.Itype.funct3[2])
                1'b0 : micro_code.funct.ld_st.funct = LoadStoreUnitFuncts::LD;
                1'b1 : micro_code.funct.ld_st.funct = LoadStoreUnitFuncts::LDU;
            endcase
            unique case(inst.Itype.funct3[1:0])
                2'b00 : micro_code.funct.ld_st.bytes = LoadStoreUnitBytes::BYTE;
                2'b01 : micro_code.funct.ld_st.bytes = LoadStoreUnitBytes::HALF;
                2'b10 : micro_code.funct.ld_st.bytes = LoadStoreUnitBytes::WORD;
                default: micro_code.funct.ld_st.bytes = LoadStoreUnitBytes::Unknown;
            endcase
            micro_code.ld_st_en = 1;
            micro_code.br_en = 0;
            micro_code.csr_en = 0;
            micro_code.jump_en = 0;
        end
        7'b01000_11 : begin // Store
            inst_type = SType;
            micro_code.rd_src = RdSrc::NotUsed;
            micro_code.alu = alu_disable;
            micro_code.imm_adder_src = ImmAdderSrc::RS1;
            micro_code.funct.ld_st.funct = LoadStoreUnitFuncts::ST;
            unique case(inst.Stype.funct3[1:0])
                2'b00 : micro_code.funct.ld_st.bytes = LoadStoreUnitBytes::BYTE;
                2'b01 : micro_code.funct.ld_st.bytes = LoadStoreUnitBytes::HALF;
                2'b10 : micro_code.funct.ld_st.bytes = LoadStoreUnitBytes::WORD;
                default: micro_code.funct.ld_st.bytes = LoadStoreUnitBytes::Unknown;
            endcase
            micro_code.ld_st_en = 1;
            micro_code.br_en = 0;
            micro_code.csr_en = 0;
            micro_code.jump_en = 0;
        end
        7'b00100_11 : begin // Imm-Reg Arithmetic
            if(inst.Itype.funct3 inside {3'b001, 3'b101, 3'b101})begin
                inst_type = ITypeShift;
            end else begin
                inst_type = IType;
            end
            micro_code.imm_adder_src = 'x;
            micro_code.rd_src = RdSrc::ALU;
            unique case({inst.Itype.imm10_0[10], inst.Itype.funct3}) inside
                4'b?000 : micro_code.alu.funct = ALUFuncts::ADD;
                4'b0001 : micro_code.alu.funct = ALUFuncts::SLL;
                4'b?010 : micro_code.alu.funct = ALUFuncts::SLT;
                4'b?011 : micro_code.alu.funct = ALUFuncts::SLTU;
                4'b?100 : micro_code.alu.funct = ALUFuncts::XOR;
                4'b0101 : micro_code.alu.funct = ALUFuncts::SRL;
                4'b1101 : micro_code.alu.funct = ALUFuncts::SRA;
                4'b?110 : micro_code.alu.funct = ALUFuncts::OR;
                4'b?111 : micro_code.alu.funct = ALUFuncts::AND;
                default: micro_code.alu.funct = ALUFuncts::Unknown;
            endcase
            micro_code.alu.op1_src = OP1Src::RS1;
            micro_code.alu.op2_src = OP2Src::IMM;
            micro_code.alu.en = 1;
            micro_code.br_en = 0;
            micro_code.ld_st_en = 0;
            micro_code.csr_en = 0;
            micro_code.jump_en = 0;
        end
        7'b01100_11 : begin // Reg-Reg Arithmetic
            inst_type = RType;
            micro_code.rd_src = RdSrc::ALU;
            micro_code.imm_adder_src = 'x;
            unique if(inst.Rtype.funct7[1:0] == 2'b01)begin
                unique case(inst.Rtype.funct3)
                    3'b000 : micro_code.alu.funct = ALUFuncts::MUL;
                    3'b001 : micro_code.alu.funct = ALUFuncts::MULH;
                    3'b010 : micro_code.alu.funct = ALUFuncts::MULHSU;
                    3'b011 : micro_code.alu.funct = ALUFuncts::MULHU;
                    // 3'b100 : micro_code.alu.funct = ALUFuncts::DIV;
                    // 3'b101 : micro_code.alu.funct = ALUFuncts::DIVU;
                    // 3'b110 : micro_code.alu.funct = ALUFuncts::REM;
                    // 3'b111 : micro_code.alu.funct = ALUFuncts::REMU;
                    default: micro_code.alu.funct = ALUFuncts::Unknown;
                endcase
            end else begin
                unique case({inst.Rtype.funct7[5], inst.Rtype.funct3})
                    4'b0000 : micro_code.alu.funct = ALUFuncts::ADD;
                    4'b1000 : micro_code.alu.funct = ALUFuncts::SUB;
                    4'b0001 : micro_code.alu.funct = ALUFuncts::SLL;
                    4'b0010 : micro_code.alu.funct = ALUFuncts::SLT;
                    4'b0011 : micro_code.alu.funct = ALUFuncts::SLTU;
                    4'b0100 : micro_code.alu.funct = ALUFuncts::XOR;
                    4'b0101 : micro_code.alu.funct = ALUFuncts::SRL;
                    4'b1101 : micro_code.alu.funct = ALUFuncts::SRA;
                    4'b0110 : micro_code.alu.funct = ALUFuncts::OR;
                    4'b0111 : micro_code.alu.funct = ALUFuncts::AND;
                    default: micro_code.alu.funct = ALUFuncts::Unknown;
                endcase
            end
            micro_code.alu.op1_src = OP1Src::RS1;
            micro_code.alu.op2_src = OP2Src::RS2;
            micro_code.alu.en = 1;
            micro_code.br_en = 0;
            micro_code.ld_st_en = 0;
            micro_code.csr_en = 0;
            micro_code.jump_en = 0;
        end
        7'b11100_11 : begin // CSR, ECALL or EBREAK
            inst_type = CSRType;
            micro_code.imm_adder_src = 'x;
            unique case(inst.CSRtype.funct3[2])
                1'b0 : micro_code.funct.csr.rs1_src = RS1Src::REG;
                1'b1 : micro_code.funct.csr.rs1_src = RS1Src::ADDR;
            endcase
            micro_code.rd_src = RdSrc::CSR;
            micro_code.alu = alu_disable;
            micro_code.br_en = 0;
            micro_code.ld_st_en = 0;
            unique case(inst.CSRtype.funct3[1:0])
                2'b00 : micro_code.funct.csr.funct = CSRUnitFuncts::ECallEBreak;
                2'b01 : micro_code.funct.csr.funct = CSRUnitFuncts::ReadWrite;
                2'b10 : micro_code.funct.csr.funct = CSRUnitFuncts::ReadSet;
                2'b11 : micro_code.funct.csr.funct = CSRUnitFuncts::ReadClear;
            endcase
            micro_code.csr_en = 1;
            micro_code.jump_en = 0;
        end
        7'b00011_11 : begin // fence or fence.i
            inst_type = FenceType;
            micro_code.rd_src = RdSrc::NotUsed;
            micro_code.imm_adder_src = 'x;
            micro_code.alu = alu_disable;
            micro_code.br_en = 0;
            unique case(inst.Itype.funct3)
                3'b000 : micro_code.funct.ld_st.funct = LoadStoreUnitFuncts::FENCE;
                3'b001 : micro_code.funct.ld_st.funct = LoadStoreUnitFuncts::FENCEI;
                default : micro_code.funct.ld_st.funct = LoadStoreUnitFuncts::Unknown;
            endcase
            micro_code.funct.ld_st.bytes = LoadStoreUnitBytes::Unknown;
            micro_code.ld_st_en = 1;
            micro_code.csr_en = 0;
            micro_code.jump_en = 0;
        end
        default: begin
            inst_type = IllegalType;
            micro_code.imm_adder_src = 'x;
            micro_code.rd_src = RdSrc::NotUsed;
            micro_code.alu = alu_disable;
            micro_code.funct = 'x;
            micro_code.br_en = 0;
            micro_code.ld_st_en = 0;
            micro_code.csr_en = 0;
            micro_code.jump_en = 0;
        end
    endcase
end

// depend on Instruction Type
always_comb begin
    micro_code.pc = pc;
    unique case(inst_type)
        RType : begin
            micro_code.rs1_addr = inst.Rtype.rs1;
            micro_code.rs2_addr = inst.Rtype.rs2;
            micro_code.rd_addr = inst.Rtype.rd;
            micro_code.rd_en = 1;
            micro_code.imm_data = 32'bx;
        end
        IType : begin
            micro_code.rs1_addr = inst.Itype.rs1;
            micro_code.rs2_addr = 5'bx;
            micro_code.rd_addr = inst.Itype.rd;
            micro_code.rd_en = 1;
            micro_code.imm_data = {{21{inst.Itype.imm11}}, inst.Itype.imm10_0};
        end
        ITypeShift : begin
            micro_code.rs1_addr = inst.Itype.rs1;
            micro_code.rs2_addr = 5'bx;
            micro_code.rd_addr = inst.Itype.rd;
            micro_code.rd_en = 1;
            micro_code.imm_data = {27'b0, inst.Itype.imm10_0[4:0]};
        end
        SType : begin
            micro_code.rs1_addr = inst.Stype.rs1;
            micro_code.rs2_addr = inst.Stype.rs2;
            micro_code.rd_addr = 5'bx;
            micro_code.rd_en = 0;
            micro_code.imm_data = {{21{inst.Stype.imm11}}, inst.Stype.imm10_5, inst.Stype.imm4_0};
        end
        BType : begin
            micro_code.rs1_addr = inst.Btype.rs1;
            micro_code.rs2_addr = inst.Btype.rs2;
            micro_code.rd_addr = 5'bx;
            micro_code.rd_en = 0;
            micro_code.imm_data = {{20{inst.Btype.imm12}}, inst.Btype.imm11, inst.Btype.imm10_5, inst.Btype.imm4_1, 1'b0};
        end
        UType : begin
            micro_code.rs1_addr = 5'bx;
            micro_code.rs2_addr = 5'bx;
            micro_code.rd_addr = inst.Utype.rd;
            micro_code.rd_en = 1;
            micro_code.imm_data = {inst.Utype.imm31_12, 12'b0};
        end
        JType : begin
            micro_code.rs1_addr = 5'bx;
            micro_code.rs2_addr = 5'bx;
            micro_code.rd_addr = inst.Jtype.rd;
            micro_code.rd_en = 1;
            micro_code.imm_data = {{12{inst.Jtype.imm20}}, inst.Jtype.imm19_12, inst.Jtype.imm11, inst.Jtype.imm10_1, 1'b0};
        end
        CSRType : begin
            micro_code.rs1_addr = inst.CSRtype.rs1;
            micro_code.rs2_addr = 5'bx;
            micro_code.rd_addr = inst.Utype.rd;
            micro_code.rd_en = 1;
            micro_code.imm_data = {20'b0, inst.CSRtype.csr};
        end
        default: begin
            micro_code.rs1_addr = 0;
            micro_code.rs2_addr = 0;
            micro_code.rd_addr = 0;
            micro_code.rd_en = 0;
            micro_code.imm_data = 32'bx;
        end
    endcase
end

endmodule

