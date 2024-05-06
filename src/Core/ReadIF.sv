interface ReadIF;
    logic[31:0] addr;
    logic[31:0] data;
    logic avalid;
    logic valid;

    modport Master(
        output addr, avalid,
        input data, valid
    );
    modport Slave(
        input addr, avalid,
        output data, valid
    );
endinterface