`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 08:54:43 PM
// Design Name: 
// Module Name: Multiplexor_tb
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


module Multi_tb
#(
    parameter CLK_FREQUENCY = 200000000
);
    localparam T_CLK = 20; // ns
    
    logic [3:0]i_x = '0; bit i_sel = 2'b00;
    
    Lab1Multiplexor m0 (.i_x(i_s),.i_sel(i_sel));
    
    always #(T_CLK/2)
    begin
    i_x[3]=!i_x[3];
    end
    
    always #(1.5*T_CLK/2)
    begin
    //#(1.5*T_CLK) i_x[0]=!i_x[0];
    i_x[2]=!i_x[2];
    end
    
    always #((T_CLK-5)/2)
    begin
    //#(1.5*T_CLK) i_x[0]=!i_x[0];
    i_x[1]=!i_x[1];
    end
    
    always #(0.8*T_CLK/2)
    begin
    //#(1.5*T_CLK) i_x[0]=!i_x[0];
    i_x[0]=!i_x[0];
    end
    
endmodule

