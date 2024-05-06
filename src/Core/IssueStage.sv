`include "MicroCode.svh"

module IssueStage(
    input logic clk,
    input logic rst_n,

    input logic pred_miss,
    input logic micro_code_valid,
    input MicroCode micro_code,

    input logic exe_busy,
    input logic rd_en,
    input logic[4:0] rd_addr,
    input logic[31:0] rd_data,

    output logic exe_en,
    output MicroCode exe_microcode,
    output RV32Consts::IntReg rs1_data,
    output RV32Consts::IntReg rs2_data
);

RV32Consts::IntReg XRegs[31:0]; // x0, x1, x2, ...

logic code_queue_empty;
MicroCode issue_microcode;
logic queue_rd_en;

always_comb begin
    queue_rd_en = !exe_busy & !code_queue_empty & !pred_miss;
end

FIFO#(
    .DATA_BITS($bits(micro_code)),
    .ADDR_DEPTH(4)
) code_queue(
    .clk(clk),
    .rst_n(rst_n & (!pred_miss)),
    .rd_en(queue_rd_en),
    .dout(issue_microcode),
    .wr_en(micro_code_valid),
    .din(micro_code),
    .empty(code_queue_empty),
    .full()
);


always_ff@(posedge clk)begin
    if(rd_en && rd_addr != '0)begin
        XRegs[rd_addr] <= rd_data;
    end

    if(!rst_n)begin
        exe_en <= 0;
    end else begin
        exe_microcode <= issue_microcode;
        exe_en <= queue_rd_en;
    end

    if(issue_microcode.rs1_addr == 0)begin
        rs1_data <= 32'h0;
    end else if(issue_microcode.rs1_addr == rd_addr && rd_en)begin
        rs1_data <= rd_data;
    end else begin
        rs1_data <= XRegs[issue_microcode.rs1_addr];
    end
    if(issue_microcode.rs2_addr == 0)begin
        rs2_data <= 32'h0;
    end else if(issue_microcode.rs2_addr == rd_addr && rd_en)begin
        rs2_data <= rd_data;
    end else begin
        rs2_data <= XRegs[issue_microcode.rs2_addr];
    end
end


endmodule