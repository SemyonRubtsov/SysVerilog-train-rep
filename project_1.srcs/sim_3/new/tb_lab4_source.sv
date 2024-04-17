`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 08:40:52 PM
// Design Name: 
// Module Name: tb_lab4_source
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


module tb_lab4_source
#(
parameter T_CLK = 1.0 // ns
)
(

);
    
    logic i_clk='0;logic i_rst='0;logic i_tready='1;
    
    lab4_source u_src(
        .i_rst(i_rst),
        .i_clk(i_clk),
        
        .m_axis_tready(i_tready)
    );
    
    always #(T_CLK/2) i_clk = ~i_clk;
    initial begin
    i_tready='1;
    #10 i_rst='1;
    #16 i_rst='0;
    end
    //always #(T_CLK*10e4) i_snd = ~i_snd;
    
endmodule
