`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 08:19:34 PM
// Design Name: 
// Module Name: lab1_mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab1_mux
#(
    parameter INPUT_WIDTH = 4,
    parameter SEL_WIDTH=int'($ceil($clog2(INPUT_WIDTH)))
)
(
        input logic [INPUT_WIDTH-1:0] i_x,
        input logic [SEL_WIDTH-1:0] i_sel,
        output logic o_f
);



always @ (*) begin
    o_f=i_x[i_sel];
//    case (i_sel)
//        0: o_f = i_x[0];
//        1: o_f = i_x[1];
//        2: o_f = i_x[2];
//        3: o_f = i_x[3];
//        default : o_f = 0;
//    endcase
end

endmodule
