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

//interface if_axis #(parameter int N = 1) ();
//	localparam W = 8 * N; // TDATA bit width (N - number of bytes)
	
//	logic         tready;
//	logic         tvalid;
//	logic         tlast ;
//	logic [W-1:0] tdata ;
	
//	modport m (input tready, output tvalid, tlast, tdata);
//	modport s (output tready, input tvalid, tlast, tdata);
	
//endinterface

interface if_axis #(parameter int N = 1) ();
	localparam W = 8 * N; // TDATA bit width (N - number of bytes)
	
	logic         tready;
	logic         tvalid;
	logic         tlast ;
	logic [W-1:0] tdata ;
	
	modport m (input tready, output tvalid, tlast, tdata);
	modport s (output tready, input tvalid, tlast, tdata);
	
endinterface : if_axis

module tb_lab4_source
#(
    parameter T_CLK = 1.0 // ns
)
(
    
);
    
    logic i_clk='0;logic i_rst='0;logic i_tready='1; logic tmp1='1;logic tmp2='0;
    if_axis m_axis();
    
    lab4_source u_src(
        .i_rst(i_rst),
        .i_clk(i_clk),
        
        .m_axis(m_axis)
    );
    
    always #(T_CLK/2) i_clk = ~i_clk;
    always #(T_CLK*1.9e1) tmp1 = ~tmp1;
    always #(T_CLK*2.7e1) tmp2 = ~tmp2;
    assign m_axis.tready = tmp2 & tmp1;
    initial begin
    #47 m_axis.tready='1;
    #10 i_rst='1;
    #16 i_rst='0;
    end
    //always #(T_CLK*10e4) i_snd = ~i_snd;
    
endmodule
