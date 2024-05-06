`include "../RV32Consts.svh"
`include "SysTimerConsts.svh"

interface SysTimerIF();
    SysTimerConsts::Timer timer;
    logic upper;
    RV32Consts::IntReg data;

    modport CSRUnitPort(
        output timer,
        output upper,
        input data
    );

    modport TimerUnitPort(
        input timer,
        input upper,
        output data
    );
endinterface