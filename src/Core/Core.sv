`include "Instruction.svh"
`include "MicroCode.svh"

module Core#
(
    parameter RST_INST_ADDR = 32'h0
)(
    input logic clk,
    input logic rst_n,
    ReadIF.Master inst_bus,
    ReadIF.Master data_rbus,
    WriteIF.Master data_wbus
);
import RV32Consts::*;
// ------- System Control -------

logic exe_done;
SysTimerIF sys_timer_if();
SysTimer#(
    .CyclePerTick(128)
) sys_timer (
    .clk(clk),
    .rst_n(rst_n),
    .instret_en(exe_done),
    .csr_if(sys_timer_if)
);

logic[31:0] committed_pc;
logic pred_miss;
logic inst_valid;
logic[31:0] inst;
logic[31:0] inst_pc;
logic branched;

FetchStage #(
    .RST_INST_ADDR(RST_INST_ADDR)
) fetch_stage (
    .clk(clk),
    .rst_n(rst_n),
    .committed(exe_done),
    .committed_pc(committed_pc),
    .branched(branched),
    
    .pred_miss(pred_miss),
    .inst_valid(inst_valid),
    .inst(inst),
    .inst_pc(inst_pc),
    .inst_bus(inst_bus)
);

logic micro_code_valid;
MicroCode micro_code;

DecodeStage decode_stage(
    .clk(clk),
    .rst_n(rst_n),

    .pred_miss(pred_miss),
    .inst_valid(inst_valid),
    .inst(inst),
    .inst_pc(inst_pc),

    .micro_code_valid(micro_code_valid),
    .micro_code(micro_code)
);

logic exe_busy;
logic rd_en;
logic[4:0] rd_addr;
logic[31:0] rd_data;

logic exe_en;
MicroCode exe_microcode;
IntReg rs1_data, rs2_data;

IssueStage issue_stage(
    .clk(clk),
    .rst_n(rst_n),

    .pred_miss(pred_miss),
    .micro_code_valid(micro_code_valid),
    .micro_code(micro_code),

    .exe_busy(exe_busy),
    .rd_en(rd_en),
    .rd_addr(rd_addr),
    .rd_data(rd_data),

    .exe_en(exe_en),
    .exe_microcode(exe_microcode),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

ExeStage exe_stage(
    .clk(clk),
    .rst_n(rst_n),

    .en(exe_en),
    .microcode(exe_microcode),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),

    .busy(exe_busy),
    .done(exe_done),
    .branched(branched),
    .committed_pc(committed_pc),
    .rd_en(rd_en),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    
    .sys_timer_if(sys_timer_if),
    .data_rbus(data_rbus),
    .data_wbus(data_wbus)
);

endmodule