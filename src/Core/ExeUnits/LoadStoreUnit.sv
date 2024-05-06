`include "LoadStoreUnitFuncts.svh"
`include "RV32Consts.svh"

module LoadStoreUnit(
    input logic clk,
    input logic rst_n,
    input logic en,
    input RV32Consts::IntReg addr,
    input RV32Consts::IntReg wdata,
    input LoadStoreUnitFuncts::Type funct,
    input LoadStoreUnitBytes::Type bytes,
    
    output RV32Consts::IntReg rdata,

    output logic busy,
    output logic done,
    WriteIF.Master w_bus,
    ReadIF.Master r_bus
);

logic[1:0] stat_reg;
localparam IDLE = 0;
localparam LD_BUSY = 1;
localparam ST_BUSY = 2;

always_comb begin
    busy = en | (stat_reg == LD_BUSY && !r_bus.valid) || (stat_reg == ST_BUSY && !w_bus.done);
    done = (stat_reg == LD_BUSY && r_bus.valid) || (stat_reg == ST_BUSY && w_bus.done);
end
always_ff@(posedge clk)begin
    if(!rst_n)begin
        stat_reg <= IDLE;
    end else if(en)begin
        unique case(funct)
            LoadStoreUnitFuncts::LD  : stat_reg <= LD_BUSY;
            LoadStoreUnitFuncts::LDU : stat_reg <= LD_BUSY;
            LoadStoreUnitFuncts::ST  : stat_reg <= ST_BUSY;
            default : stat_reg <= IDLE;
        endcase
    end else begin
        unique case(stat_reg)
            LD_BUSY : begin
                if(r_bus.valid) stat_reg <= IDLE;
            end
            ST_BUSY : begin
                if(w_bus.done) stat_reg <= IDLE;
            end
            default : stat_reg <= IDLE;
        endcase
    end
end

// write bus address
always_comb begin
    w_bus.valid = (en && funct == LoadStoreUnitFuncts::ST && stat_reg == IDLE);
    w_bus.addr = {addr[31:2], 2'b0};
end

// write bus data
always_comb begin
    unique case(bytes)
        LoadStoreUnitBytes::BYTE:begin
            unique case(addr[1:0])
                2'b00 : begin
                    w_bus.strb = 4'b0001;
                    w_bus.data = {24'b0, wdata[7:0]};
                end
                2'b01 : begin
                    w_bus.strb = 4'b0010;
                    w_bus.data = {16'b0, wdata[7:0], 8'b0};
                end
                2'b10 : begin
                    w_bus.strb = 4'b0100;
                    w_bus.data = {8'b0, wdata[7:0], 16'b0};
                end
                2'b11 : begin
                    w_bus.strb = 4'b1000;
                    w_bus.data = {wdata[7:0], 24'b0};
                end
            endcase
        end
        LoadStoreUnitBytes::HALF:begin
            unique case(addr[1])
                1'b0 : begin
                    w_bus.strb = 4'b0011;
                    w_bus.data = {16'b0, wdata[15:0]};
                end
                1'b1 : begin
                    w_bus.strb = 4'b1100;
                    w_bus.data = {wdata[15:0], 16'b0};
                end
            endcase
        end
        LoadStoreUnitBytes::WORD:begin
            w_bus.strb = 4'b1111;
            w_bus.data = wdata;
        end
        default : begin
            w_bus.strb = 4'b0000; // write disable
            w_bus.data = 32'b0;
        end
    endcase
end

// read bus address
always_comb begin
    r_bus.avalid = (en && funct inside {LoadStoreUnitFuncts::LD, LoadStoreUnitFuncts::LDU} && stat_reg == IDLE);
    r_bus.addr = {addr[31:2], 2'b0};
end

logic[1:0] rd_addr;
LoadStoreUnitFuncts::Type rd_funct;
LoadStoreUnitBytes::Type rd_bytes;

always_ff@(posedge clk)begin
    if(en)begin
        rd_addr <= addr[1:0];
        rd_funct <= funct;
        rd_bytes <= bytes;
    end
end

logic[7:0]  ld_byte;
logic[15:0] ld_half;
always_comb begin
    unique case(rd_addr[1:0])
        2'b00 : ld_byte = r_bus.data[7:0];
        2'b01 : ld_byte = r_bus.data[15:8];
        2'b10 : ld_byte = r_bus.data[23:16];
        2'b11 : ld_byte = r_bus.data[31:24];
    endcase
    unique case(rd_addr[1])
        1'b0 : ld_half = r_bus.data[15:0];
        1'b1 : ld_half = r_bus.data[31:16];
    endcase

    unique case(rd_funct)
        LoadStoreUnitFuncts::LD : begin
            unique case(rd_bytes)
                LoadStoreUnitBytes::BYTE : rdata = {{24{ld_byte[7]}},  ld_byte};
                LoadStoreUnitBytes::HALF : rdata = {{16{ld_half[15]}}, ld_half};
                LoadStoreUnitBytes::WORD : rdata = r_bus.data;
                default : rdata = 0;
            endcase
        end
        LoadStoreUnitFuncts::LDU : begin
            unique case(rd_bytes)
                LoadStoreUnitBytes::BYTE : rdata = {24'b0, ld_byte};
                LoadStoreUnitBytes::HALF : rdata = {16'b0, ld_half};
                LoadStoreUnitBytes::WORD : rdata = r_bus.data;
                default : rdata = 0;
            endcase
        end
        default: rdata = 0;
    endcase
end

endmodule