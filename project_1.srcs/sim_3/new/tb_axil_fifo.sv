`timescale 1ns / 1ps

module tb_axil_fifo;

axil_fifo #(
    .DUAL_CLOCK("False"), // Dual clock fifo: "True" or "False"
    .SYNC_STAGES(2), // Number of synchronization stages in dual clock mode: [2, 3, 4]
    .RESET_SYNC("False"), // Asynchronous reset synchronization: "True" or "False"
    .DEPTH('{ 32, 32, 32, 32, 32 }), // Depth of fifos, minimum is 16, actual depth will be displayed in the information of module
    .MEM_STYLE('{"Distributed", "Distributed", "Distributed", "Distributed", "Distributed"}), 
    .FEATURES('{ '0,'0,'0,'0,'0 }), // Advanced features: [ read count, prog. empty, almost empty, write count, prog. full, almost full ]     
    .PROG_FULL('{ 12, 12, 12, 12, 12 }), // Programmable full threshold
    .PROG_EMPTY('{ 4, 4, 4, 4, 4 }) // Programmable empty threshold
)
u_axil
(

);

endmodule
