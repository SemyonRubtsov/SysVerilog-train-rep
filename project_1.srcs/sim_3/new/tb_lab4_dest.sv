`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2024 07:07:08 PM
// Design Name: 
// Module Name: tb_lab4_dest
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

interface if_axis #(parameter int N = 1) ();
	localparam W = 8 * N; // TDATA bit width (N - number of bytes)
	
	logic         tready;
	logic         tvalid;
	logic         tlast ;
	logic [W-1:0] tdata ;
	
	modport m (input tready, output tvalid, tlast, tdata);
	modport s (output tready, input tvalid, tlast, tdata);
	
endinterface : if_axis

module tb_lab4_dest #(
    parameter T_CLK = 1.0 // ns
)(
    //if_axis.m m_axis
);

logic i_clk='1; reg [0:1] i_rst='0;

int tst_crc_arr[18]={'h0, 'h7f, 'hbc, 'h30, 'hdd, 'ha3, 'hb5, 'h1b, 'h2d, 'hf0, 'h7, 'h83, 'h47, 'h61, 'h91, 'h3A, 'h27, 'hdd};

if_axis #(.N(1)) m_axis ();

task send_packet;

    input int i_p_len;
    input reg [2:0] i_settings;
    
    begin
        m_axis.tvalid <= '1;
        
        if (i_settings[0]) begin
            m_axis.tdata=72; //send header
            #(T_CLK);
        end
        
        if (i_settings[1]) begin
            m_axis.tdata=i_p_len; //send length
            #(T_CLK);
        end
        
        for (int i = 0; i < i_p_len; i++) begin //send packet
            m_axis.tvalid <= '1;
			m_axis.tdata  <= i+1;
			#(T_CLK);
        end
        
        m_axis.tlast <= '1;
        if (i_settings[2]) m_axis.tdata<=tst_crc_arr[i_p_len-1]; //send real precalculated CRC
        else m_axis.tdata<=tst_crc_arr[i_p_len]; //send fake CRC
        #(T_CLK);
        
        m_axis.tlast<='0;
        m_axis.tvalid <= '0; //end packet
        #(T_CLK);
    end
endtask
    
lab4_dest u_dest(

    .i_clk(i_clk),
    .i_rst(i_rst),

    .s_axis(m_axis)
);

always #(T_CLK/2) i_clk=~i_clk;

//always #(T_CLK*20) send_packet(10);

initial begin
    i_rst = '1;
    #2;
    i_rst = '0;
    m_axis.tlast <= '0;
    
    send_packet(10,3'b111);
    send_packet(10,3'b111);
    send_packet(10,3'b111);
    send_packet(10,3'b110);
    send_packet(10,3'b101);
    send_packet(10,3'b011);
    send_packet(10,3'b001);
    send_packet(10,3'b001);
    
    #500;
    i_rst = '1;
end

endmodule
