module FIFO #(
    parameter integer DATA_BITS,
    parameter integer ADDR_DEPTH
) (
    input  logic clk,
    input  logic rst_n,
    input  logic rd_en,
    output logic[DATA_BITS-1:0] dout,
    input  logic wr_en,
    input  logic[DATA_BITS-1:0] din,
    output logic empty,
    output logic full
);

localparam RAM_LEN = 2**ADDR_DEPTH;
logic[DATA_BITS-1:0] ram[RAM_LEN-1:0];

logic[ADDR_DEPTH:0] rd_addr = 0;
logic[ADDR_DEPTH:0] wr_addr = 0;

always_comb begin
    dout = ram[rd_addr[ADDR_DEPTH-1:0]];
    
    empty = (rd_addr == wr_addr);
    full  = (
         (rd_addr[ADDR_DEPTH]     != wr_addr[ADDR_DEPTH])
      && (rd_addr[ADDR_DEPTH-1:0] == wr_addr[ADDR_DEPTH-1:0])
    );
end

always_ff @(posedge clk) begin
    if(!rst_n)begin
        rd_addr <= '0;
        wr_addr <= '0;
    end else begin
        if(rd_en)begin
            rd_addr <= rd_addr + 1;
        end else begin
            rd_addr <= rd_addr;
        end

        if(wr_en && !full)begin
            wr_addr <= wr_addr + 1;
            ram[wr_addr[ADDR_DEPTH-1:0]] <= din;
        end else begin
            wr_addr <= wr_addr;
        end
    end
end
    
endmodule