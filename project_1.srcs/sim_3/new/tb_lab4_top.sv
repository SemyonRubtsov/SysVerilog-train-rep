`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 06:42:49 PM
// Design Name: 
// Module Name: tb_lab4_top
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

//убрать лог. сигналы из sensivity list,
//проверить multiple drive, запись в регистры вместо чтения напрямую
//больше состояний, при необходимости опускать tready чтобы успевать считывать и сравнивать crc


// simple AXIS interface


logic i_ready='1;

module tb_lab4_top 
#(
parameter G_BYT = 1, // byte width       
parameter G_WID = 8 * G_BYT, // bit width
parameter T_CLK = 1.0 // ns
)
(

    // UUT generics
	//int G_BYT = 1, // byte width
	//int G_WID = 8 * G_BYT, // bit width
	
    // TB constants
	//T_CLK = 1.0 // ns
);

logic [2:0] i_aresetn = '1; // asynchronous reset, active-low
logic [2:0] rstreg = 1;
logic i_aclk    = '1; // clock
logic tb_dest_tready='1;
reg [5:0] i_p_len=4;

if_axis #(.N(G_BYT)) s_axis ();
if_axis #(.N(G_BYT)) m_axis ();

// initialize manager AXIS interface
task axis_init;
	begin
		s_axis.tvalid <= 0;
		s_axis.tlast  <= 0;
		s_axis.tdata  <= 0;
	end
endtask

// send packet to AXIS FIFO
int i = 0;
task send_pkt;
	localparam N = 100; // number of samples in packet
	begin
		for (i = 1; i <= N; i++) begin
			s_axis.tvalid <= 1;
			s_axis.tlast  <= (i == N);
			s_axis.tdata  <= i;
			#(T_CLK);
			s_axis.tvalid <= 0;
		end
		#(N*T_CLK);
	end
endtask

// simulate input signals
int k = 0;
initial begin
// init
	i_aresetn = '0;
	axis_init;
	m_axis.tready = 1;
	#(10*T_CLK);
// reset FIFO (active-low)
	i_aresetn = '1;
	#(10*T_CLK);
	i_aresetn = '0;
	#(10*T_CLK);
// send several packets
	for (k = 0; k < 8; k++) begin
		//send_pkt;
	end
// send 1st packet
	//send_pkt;
// send 2nd packet
	//send_pkt;
end

// simulate clock
always #(T_CLK/2.0) i_aclk = ~i_aclk;

always #(50) begin
    i_p_len=i_p_len+3;
    if (i_p_len=='0) i_p_len=1;
end

always #(T_CLK*284) begin
    
    i_aresetn=rstreg;
    rstreg=rstreg<<<1;
    if (rstreg=='0) rstreg=1;
    #5 i_aresetn='0;

end

always #(T_CLK*26) begin
    
    i_ready=~i_ready;

end

//axis_data_fifo_0 u_fifo (
//  .s_axis_aresetn(i_aresetn),          // input wire s_axis_aresetn
//  .s_axis_aclk(i_aclk),                // input wire s_axis_aclk
  
//  .s_axis_tvalid(s_axis.tvalid),            // input wire s_axis_tvalid
//  .s_axis_tready(s_axis.tready),            // output wire s_axis_tready
//  .s_axis_tdata(s_axis.tdata),              // input wire [7 : 0] s_axis_tdata
//  .s_axis_tlast(s_axis.tlast),              // input wire s_axis_tlast
  
//  .m_axis_tvalid(m_axis.tvalid),            // output wire m_axis_tvalid
//  .m_axis_tready(m_axis.tready),            // input wire m_axis_tready
//  .m_axis_tdata(m_axis.tdata),              // output wire [7 : 0] m_axis_tdata
//  .m_axis_tlast(m_axis.tlast),              // output wire m_axis_tlast
  
//  .axis_wr_data_count(axis_wr_data_count),  // output wire [31 : 0] axis_wr_data_count
//  .axis_rd_data_count(axis_rd_data_count),  // output wire [31 : 0] axis_rd_data_count
//  .prog_empty(prog_empty),                  // output wire prog_empty
//  .prog_full(prog_full)                    // output wire prog_full
//);

lab4_top u_lab4 (
    .i_clk(i_aclk),
    .i_rst(i_aresetn),
    .i_p_len(i_p_len),
    .i_ready(i_ready)
);

endmodule
