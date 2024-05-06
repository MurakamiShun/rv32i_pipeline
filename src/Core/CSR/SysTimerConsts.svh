`ifndef SYS_TIMER_CONSTS_SVH
`define SYS_TIMER_CONSTS_SVH

package SysTimerConsts;
    typedef enum logic[1:0] { CYCLE, TIME, INSTRET } Timer;
endpackage

`endif