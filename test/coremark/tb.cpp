#include <iostream>
#include <memory>
#include <vector>
#include <iomanip>
#include <verilated.h>
#include <utility>
#include "Vtop.h"

#include "Vtop_WriteIF.h"
#include "Vtop_ReadIF.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    // Instance
    auto top = std::make_unique<Vtop>();
    const uint64_t sim_cycles = 3'000'000'000;
    // -- reset --
    top->clk = 0;
    top->rst_n = 0;
    top->eval();
    top->clk = 1;
    top->rst_n = 0;
    top->eval();
    top->rst_n = 1;
    for(uint64_t i = 0; i < sim_cycles; ++i){
        top->clk = 0;
        top->eval();
        top->clk = 1;
        top->eval();
        if(top->uart_tx_en){
            std::cout << (char)top->uart_data;
        }

        // if(top->top__DOT__core__DOT__exe_en){
            
        //     std::cout << std::hex << std::setw(6) << (top->top__DOT__core__DOT__inst_pc)
        //     << ", inst valid:" << std::setw(1) << int(top->top__DOT__core__DOT__inst_valid)
        //     << ", inst:" << std::setw(8) << top->top__DOT__core__DOT____Vcellout__fetch_stage__inst
        //     << ", exe pc:" << std::setw(6) << (top->top__DOT__core__DOT__exe_stage__DOT__pc4 - 4)
        //     << ", rs1:" << std::setw(8) << top->top__DOT__core__DOT__exe_stage__DOT__rs1_fwd
        //     << ", rs2:" << std::setw(8) << top->top__DOT__core__DOT__exe_stage__DOT__rs2_fwd
        //     << ", alu:" << std::setw(8) << top->top__DOT__core__DOT__exe_stage__DOT__alu_result
        //     << ", ld data:" << std::setw(8) << top->top__DOT__core__DOT__exe_stage__DOT__ld_data
        //     << ", rd en:" << std::setw(1) << (int)top->top__DOT__core__DOT__rd_en
        //     << ", rd addr:" << std::dec << std::setw(2) << (int)top->top__DOT__core__DOT__rd_addr
        //     << ", rd data:" << std::hex << std::setw(8) << top->top__DOT__core__DOT__rd_data
        //     << std::endl;

        //     for(int i = 0; i < 32; i+=4){
        //         std::cout
        //          << "\t"<< std::dec << std::setw(2) << i
        //          << ":" << std::hex << std::setw(8) << top->top__DOT__core__DOT__issue_stage__DOT__XRegs[i]
        //          << " , " << std::dec << std::setw(2) << i+1
        //          << ":" << std::hex << std::setw(8) << top->top__DOT__core__DOT__issue_stage__DOT__XRegs[i+1]
        //          << " , " << std::dec << std::setw(2) << i+2
        //          << ":" << std::hex << std::setw(8) << top->top__DOT__core__DOT__issue_stage__DOT__XRegs[i+2]
        //          << " , " << std::dec << std::setw(2) << i+3
        //          << ":" << std::hex << std::setw(8) << top->top__DOT__core__DOT__issue_stage__DOT__XRegs[i+3]
        //         << std::endl;
        //     }
        //     std::cout << std::endl;
            
        // }
    }
}