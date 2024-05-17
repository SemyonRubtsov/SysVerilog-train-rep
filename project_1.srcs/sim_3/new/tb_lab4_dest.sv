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

module tb_lab4_dest #(
    parameter T_CLK = 1.0 // ns
)(
    //if_axis.m m_axis
);

logic i_clk='1; reg [0:1] i_rst='0; logic i_ready=1;

int tst_crc_arr[18]={'h0, 'h7f, 'hbc, 'h30, 'hdd, 'ha3, 'hb5, 'h1b, 'h2d, 'hf0, 'h7, 'h83, 'h47, 'h61, 'h91, 'h3A, 'h27, 'hdd};

if_axis #(.N(1)) m_axis ();

task send_packet;

    input int i_p_len;
    input reg [3:0] i_settings;
    
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
        m_axis.tvalid <= '0;
        #(T_CLK);
        m_axis.tvalid <= '1;
        
        m_axis.tlast <= '1;
        if (i_settings[2]) m_axis.tdata<=tst_crc_arr[i_p_len-1]; //send real precalculated CRC
        else m_axis.tdata<=tst_crc_arr[i_p_len]; //send fake CRC
        #(T_CLK);
        
        m_axis.tlast<='0;
        m_axis.tvalid <= '0; //end packet
        if (i_settings[3]) #(T_CLK);
    end
endtask
    
lab4_dest_v2 u_dest(

    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_ready(i_ready),

    .s_axis(m_axis)
);

always #(T_CLK/2) i_clk=~i_clk;

always #(T_CLK*20) i_ready=~i_ready;

initial begin
    i_rst = '1;
    #2;
    i_rst = '0;
    m_axis.tlast <= '0;
    
    send_packet(10,4'b1111); //good
    send_packet(12,4'b0111); //good
    send_packet(8,4'b1111); //good
    send_packet(10,4'b1111); //bad
    send_packet(10,4'b1101); //bad
    
    send_packet(4,4'b0111);//good
    send_packet(6,4'b0111);//good
    
    send_packet(10,4'b1011); //bad
    send_packet(10,4'b1001); //bad
    send_packet(8,4'b1001); //bad
    send_packet(10,4'b0111); //good
    send_packet(10,4'b1111); //good
    //m_axis.tvalid <= '0;
    #500;
    i_rst = '1;
    #590;
    i_rst = '0;
    
    send_packet(10,3'b111);
    m_axis.tvalid <= '0;
end

endmodule
