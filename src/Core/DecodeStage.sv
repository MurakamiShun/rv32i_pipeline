module DecodeStage(
    input  logic clk,
    input  logic rst_n,

    input logic pred_miss,
    input logic inst_valid,
    input Instruction inst,
    input logic[31:0] inst_pc,

    output logic micro_code_valid,
    output MicroCode micro_code
);

MicroCode dec_micro_code;

Decoder decoder(
    .inst(inst),
    .pc(inst_pc),
    .micro_code(dec_micro_code)
);

always_ff@(posedge clk)begin
    if(!rst_n)begin
        micro_code_valid <= 0;
    end else begin
        micro_code_valid <= inst_valid & !pred_miss;
        micro_code <= dec_micro_code;
    end
end

endmodule