`include "../RV32Consts.svh"
`include "SysTimerConsts.svh"

module SysTimer#(
    parameter CyclePerTick = 128
)(
    input logic clk,
    input logic rst_n,
    input logic instret_en,
    SysTimerIF.TimerUnitPort csr_if
);
import RV32Consts::*;
import SysTimerConsts::*;

IntReg cycle  = 0;
IntReg cycleh = 0;
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cycle  <= 0;
        cycleh <= 0;
    end else begin
        cycle  <= cycle + 1;
        cycleh <= cycleh + (&cycle ? 1 : 0);
    end
end

IntReg tick  = 0;
IntReg time_reg  = 0;
IntReg timeh_reg = 0;
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        tick  <= 0;
        time_reg  <= 0;
        timeh_reg <= 0;
    end else if(tick == CyclePerTick - 1) begin
        tick  <= 0;
        time_reg  <= time_reg + 1;
        timeh_reg <= timeh_reg + (&time_reg ? 1 : 0);
    end else begin
        tick  <= tick + 1;
        time_reg  <= time_reg;
        timeh_reg <= timeh_reg;
    end
end


IntReg instret  = 0;
IntReg instreth = 0;
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        instret  <= 0;
        instreth <= 0;
    end else if(instret_en) begin
        instret  <= instret + 1;
        instreth <= instreth + (&instret ? 1 : 0);
    end else begin
        instret  <= instret;
        instreth <= instreth;
    end
end

always_comb begin
    if(csr_if.upper)begin
        unique case(csr_if.timer)
            CYCLE   : csr_if.data = cycleh;
            TIME    : csr_if.data = timeh_reg;
            INSTRET : csr_if.data = instreth;
            default : csr_if.data = 0;
        endcase
    end else begin
        unique case(csr_if.timer)
            CYCLE   : csr_if.data = cycle;
            TIME    : csr_if.data = time_reg;
            INSTRET : csr_if.data = instret;
            default : csr_if.data = 0;
        endcase
    end
end

endmodule