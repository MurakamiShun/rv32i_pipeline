verilator --cc --exe --build -CFLAGS "--std=c++20" top.sv tb.cpp -I../../src/Core -I../../src/Core/CSR -I../../src/Core/ExeUnits -I.
./obj_dir/Vtop