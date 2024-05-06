module top(
    input logic clk,
    input logic rst_n,
    output logic[31:0] uart_data,
    output logic uart_tx_en,
    output logic[31:0] pc
);

ReadIF inst_bus();
ReadIF data_rbus();
WriteIF data_wbus();

Core#(
    .RST_INST_ADDR(32'h10000)
) core (
    .clk(clk),
    .rst_n(rst_n),
    .inst_bus(inst_bus),
    .data_rbus(data_rbus),
    .data_wbus(data_wbus)
);

// ---- UART ----
localparam uart_tx_addr = 32'h1000;

always_comb begin
    if(data_wbus.addr == uart_tx_addr && data_wbus.valid)begin
        uart_tx_en = 1;
        uart_data = data_wbus.data;
    end else begin
        uart_tx_en = 0;
        uart_data = 0;
    end
end



localparam RAM_BASE_ADDR = 32'h10000;
localparam RAM_ADDR_WIDTH = 15; // 0x8000
logic[31:0] ram[2**(RAM_ADDR_WIDTH-2)-1:0];

initial begin
    //$readmemh("src/coremark_inst.hex", ram);
    $readmemh("rv32i_test/rv32ui-p-sh.hex", ram);
end

logic[31:0] data_wbus_ram_addr;
logic[31:0] w_addr;

always_comb begin
    pc = inst_bus.addr - RAM_BASE_ADDR;
    w_addr = (data_wbus.valid ? data_wbus.addr : data_rbus.addr);
    data_wbus_ram_addr = w_addr - RAM_BASE_ADDR;
end

always_ff@(posedge clk)begin
    if(w_addr >= RAM_BASE_ADDR)begin
        if(data_wbus.valid && data_wbus.strb[0])begin
            ram[data_wbus_ram_addr[RAM_ADDR_WIDTH-1:2]][7:0] <= data_wbus.data[7:0];
        end else begin
            data_rbus.data[7:0] <= ram[data_wbus_ram_addr[RAM_ADDR_WIDTH-1:2]][7:0];
        end
        if(data_wbus.valid && data_wbus.strb[1])begin
            ram[data_wbus_ram_addr[RAM_ADDR_WIDTH-1:2]][15:8] <= data_wbus.data[15:8];
        end else begin
            data_rbus.data[15:8] <= ram[data_wbus_ram_addr[RAM_ADDR_WIDTH-1:2]][15:8];
        end
        if(data_wbus.valid && data_wbus.strb[2])begin
            ram[data_wbus_ram_addr[RAM_ADDR_WIDTH-1:2]][23:16] <= data_wbus.data[23:16];
        end else begin
            data_rbus.data[23:16] <= ram[data_wbus_ram_addr[RAM_ADDR_WIDTH-1:2]][23:16];
        end
        if(data_wbus.valid && data_wbus.strb[3])begin
            ram[data_wbus_ram_addr[RAM_ADDR_WIDTH-1:2]][31:24] <= data_wbus.data[31:24];
        end else begin
            data_rbus.data[31:24] <= ram[data_wbus_ram_addr[RAM_ADDR_WIDTH-1:2]][31:24];
        end
    end

    if(data_wbus.valid)begin
        data_wbus.done <= 1;
    end else begin
        data_wbus.done <= 0;
    end
    
    if(data_rbus.avalid)begin
        data_rbus.valid <= 1;
    end else begin
        data_rbus.valid <= 0;
    end


    if(inst_bus.avalid)begin
        inst_bus.data <= ram[pc[RAM_ADDR_WIDTH-1:2]];
        inst_bus.valid <= 1;
    end else begin
        inst_bus.valid <= 0;
    end
end


endmodule