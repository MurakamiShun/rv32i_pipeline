module FetchStage#(
    parameter RST_INST_ADDR = 32'h0
)(
    input  logic clk,
    input  logic rst_n,
    input logic committed,
    input logic[31:0] committed_pc,
    
    output logic pred_miss,
    output logic inst_valid,
    output Instruction inst,
    output logic[31:0] inst_pc,
    ReadIF.Master inst_bus
);

logic[31:0] pred_committed_pc;
always_comb begin
    pred_miss = committed && (committed_pc != pred_committed_pc);
end

logic history_full;
logic[31:0] current_pc;

logic[31:0] next_pc;
always_comb begin
    next_pc = (pred_miss ? committed_pc : current_pc) + 32'h4;
end

FIFO #(
    .DATA_BITS(32),
    .ADDR_DEPTH(4)
) pred_pc_history(
    .clk(clk),
    .rst_n(rst_n & !pred_miss),
    .rd_en(committed),
    .dout(pred_committed_pc),
    .wr_en(inst_valid),
    .din(current_pc),
    .empty(),
    .full(history_full)
);

always_comb begin
    if(!rst_n)begin
        inst_bus.addr = RST_INST_ADDR;
        inst_bus.avalid = 0;
    end else if(pred_miss)begin
        inst_bus.addr = committed_pc;
        inst_bus.avalid = 1;
    end else if(inst_bus.valid)begin
        inst_bus.addr = next_pc;
        inst_bus.avalid = !history_full;
    end else begin
        inst_bus.addr = current_pc;
        inst_bus.avalid = !history_full;
    end
end

always_ff@(posedge clk)begin
    if(!rst_n)begin
        current_pc <= RST_INST_ADDR;
        inst_valid <= 0;
    end else if(pred_miss)begin
        current_pc <= committed_pc;
        inst.inst32 <= 32'h0;
        inst_valid <= 0;
    end else if(inst_bus.valid)begin
        current_pc <= next_pc;
        inst_pc <= current_pc;
        inst.inst32 <= inst_bus.data;
        inst_valid <= 1;
    end else begin
        current_pc <= current_pc;
        inst_pc <= 32'h0;
        inst.inst32 <= 32'h0;
        inst_valid <= 0;
    end

end


endmodule