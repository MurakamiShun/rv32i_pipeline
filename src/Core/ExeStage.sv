`include "MicroCode.svh"

module ExeStage(
    input logic clk,
    input logic rst_n,

    input logic en,
    input MicroCode microcode,
    input RV32Consts::IntReg rs1_data,
    input RV32Consts::IntReg rs2_data,

    output logic busy,
    output logic done,
    output logic[31:0] committed_pc,
    output logic branched,
    output logic rd_en,
    output logic[4:0] rd_addr,
    output logic[31:0] rd_data,
    
    SysTimerIF sys_timer_if,
    ReadIF.Master data_rbus,
    WriteIF.Master data_wbus
);
import RV32Consts::*;

logic br_token;

MicroCode microcode_reg;
MicroCode microcode_latch;
always_ff@(posedge clk)begin
    if(en) microcode_reg <= microcode;
end
always_comb begin
    microcode_latch = en ? microcode : microcode_reg;
end

always_comb begin
    busy = ld_st_busy;
    done = ld_st_done
        | (!microcode_latch.ld_st_en & microcode_latch.alu.en & en)
        | (microcode_latch.br_en & en)
        | (microcode_latch.jump_en & en)
        | (microcode_latch.csr_en & en);
    branched = microcode_latch.br_en & en;
end

IntReg rs1_fwd, rs2_fwd;

always_comb begin
    if(rd_en && rd_addr == microcode_latch.rs1_addr)begin
        rs1_fwd = rd_data;
    end else begin
        rs1_fwd = rs1_data;
    end
    if(rd_en && rd_addr == microcode_latch.rs2_addr)begin
        rs2_fwd = rd_data;
    end else begin
        rs2_fwd = rs2_data;
    end
end

// imm adder
logic[31:0] imm_adder_result;
logic[31:0] imm_adder_src;
always_comb begin
    unique case(microcode_latch.imm_adder_src)
        ImmAdderSrc::RS1 : imm_adder_src = rs1_fwd;
        ImmAdderSrc::PC  : imm_adder_src = microcode_latch.pc;
    endcase
    imm_adder_result = imm_adder_src + microcode_latch.imm_data;
end

// pc
logic[31:0] pc4;
always_comb begin
    pc4 = microcode_latch.pc + 32'h4;
    committed_pc = (en & (br_token | microcode_latch.jump_en)) ? imm_adder_result : pc4;
end


// alu
IntReg alu_op1, alu_op2;
IntReg alu_result;
always_comb begin
    unique case(microcode_latch.alu.op1_src)
        OP1Src::RS1  : alu_op1 = rs1_fwd;
        OP1Src::ZERO : alu_op1 = 32'b0;
        OP1Src::PC   : alu_op1 = microcode_latch.pc;
        default      : alu_op1 = 32'bx;
    endcase
    unique case(microcode_latch.alu.op2_src)
        OP2Src::RS2 : alu_op2 = rs2_fwd;
        OP2Src::IMM : alu_op2 = microcode_latch.imm_data;
        default     : alu_op2 = 32'bx;
    endcase
end
ALU alu(
    .op1(alu_op1),
    .op2(alu_op2),
    .funct(microcode_latch.alu.funct),
    .result(alu_result)
);

BranchUnit br_unit(
    .en(microcode_latch.br_en & en),
    .op1(rs1_fwd),
    .op2(rs2_fwd),
    .funct(microcode_latch.funct.br),
    .token(br_token)
);

// csr
IntReg csr_wdata, csr_rdata;
always_comb begin
    unique case(microcode_latch.funct.csr.rs1_src)
        RS1Src::REG  : csr_wdata = rs1_fwd;
        RS1Src::ADDR : csr_wdata = {27'b0, microcode_latch.rs1_addr};
        default      : csr_wdata = 32'bx;
    endcase
end
CSRUnit csr_unit(
    .en(microcode_latch.csr_en & en),
    .addr(microcode_latch.imm_data[11:0]),
    .in_data(csr_wdata),
    .funct(microcode_latch.funct.csr.funct),
    .out_data(csr_rdata),
    .sys_timer_if(sys_timer_if)
);

// load store
logic ld_st_busy, ld_st_done;
IntReg ld_data;
LoadStoreUnit ld_st_unit(
    .clk(clk),
    .rst_n(rst_n),
    .en(microcode_latch.ld_st_en & en),
    .addr(imm_adder_result),
    .wdata(rs2_fwd),
    .funct(microcode_latch.funct.ld_st.funct),
    .bytes(microcode_latch.funct.ld_st.bytes),

    .rdata(ld_data),

    .busy(ld_st_busy),
    .done(ld_st_done),
    .w_bus(data_wbus),
    .r_bus(data_rbus)
);

// rd
always_ff@(posedge clk) begin
    rd_en <= microcode_latch.rd_en & done;
    if(done)begin
        rd_addr <= microcode_latch.rd_addr;
        if(microcode_latch.rd_addr == '0)begin
            rd_data <= 32'h0;
        end else begin
            unique case(microcode_latch.rd_src)
                RdSrc::ALU : rd_data <= alu_result;
                RdSrc::CSR : rd_data <= csr_rdata;
                RdSrc::LD  : rd_data <= ld_data;
                RdSrc::PC4 : rd_data <= pc4;
                default : rd_data <= 32'bx;
            endcase
        end
    end
end


endmodule