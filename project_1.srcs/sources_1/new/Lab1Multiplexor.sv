`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 08:19:34 PM
// Design Name: 
// Module Name: Lab1Multiplexor
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


module Lab1Multiplexor(
        input logic [3:0] i_x,
        input logic [1:0] i_sel,
        output logic o_f
    );
always @ (*) begin
    case (i_sel)
        2'b00: o_f<=i_x[0];
        2'b01: o_f<=i_x[1];
        2'b10: o_f<=i_x[2];
        2'b11: o_f<=i_x[3];
        default : o_f<=0;
    endcase
end

endmodule
