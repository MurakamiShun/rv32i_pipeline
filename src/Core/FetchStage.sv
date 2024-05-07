module FetchStage#(
    parameter RST_INST_ADDR = 32'h0
)(
    input  logic clk,
    input  logic rst_n,
    input logic committed,
    input logic[31:0] committed_pc,
    input logic branched,
    
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

logic[1:0] bi_cnt[7:0];
logic[31:0] last_committed_pc;
logic[31:0] last_committed_pc4;
always_ff@(posedge clk)begin
    if(committed)begin
        last_committed_pc4 <= committed_pc + 32'h4;
        last_committed_pc <= committed_pc;
    end
    if(branched & committed) begin
        if(last_committed_pc4 == committed_pc) begin // not token
            bi_cnt[last_committed_pc[4:2]] <= bi_cnt[last_committed_pc[4:2]] == 0 ? 0 : (bi_cnt[last_committed_pc[4:2]] - 1);
        end else begin // token
            bi_cnt[last_committed_pc[4:2]] <= bi_cnt[last_committed_pc[4:2]] == 2'b11 ? 2'b11 : (bi_cnt[last_committed_pc[4:2]] + 1);
        end
    end
end

logic[31:0] next_pc;
function automatic logic[31:0] predicate_pc(input logic[31:0] pc, input Instruction last_inst);
    if(last_inst.common.opcode == 7'b11000_11 && bi_cnt[current_pc[4:2]][1])begin
        return pc + {{20{last_inst.Btype.imm12}}, last_inst.Btype.imm11, last_inst.Btype.imm10_5, last_inst.Btype.imm4_1, 1'b0};
    end else begin
        return pc + 32'h4;
    end
endfunction

always_comb begin
    next_pc = pred_miss ? (committed_pc + 32'h4) : predicate_pc(current_pc, inst_bus.data);
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