`timescale 1ns / 1ps

module tb_axis_fifo;

    localparam DW = 8;
    localparam FIFO_DEPTH = 256;
    localparam DUAL_CLOCK = "False";
    localparam PACKET_MODE = "True";
    localparam MEM_STYLE = "Distributed";
    localparam SYNC_STAGES = 2;
    localparam RESET_SYNC = "True";
    localparam RESET_VALUE = 0;
    localparam PAYLOAD_MASK = 7'b000_1001;
    localparam FEATURES = 8'hFF;
    localparam PROG_FULL = 11;
    localparam PROG_EMPTY = 5;

    localparam SYNC_FIFO = ( DUAL_CLOCK == "True" ) ? "independent_clock" : "common_clock";
    localparam PACKET_FIFO = ( PACKET_MODE == "True" ) ? "true" : "false";

    localparam W_CLK_PRD = 1.0;
    localparam R_CLK_PRD = ( DUAL_CLOCK == "False" ) ? W_CLK_PRD : 2.0;
    localparam C_CLK_MAX = ( W_CLK_PRD > R_CLK_PRD ) ? W_CLK_PRD : R_CLK_PRD;

    bit w_fifo_a_rst_n = '1;
    bit c_fifo_w_clk_p = '0;
    bit w_fifo_w_rst_n = '1;
    bit c_fifo_r_clk_p = '0;
    bit w_fifo_r_rst_n = '1;

    logic                   a_fifo_a_tfull = '0;
    logic                   a_fifo_p_tfull = '0;
    logic [$clog2(DW):0]    a_fifo_w_count = '0;
    logic                   a_fifo_a_empty = '0;
    logic                   a_fifo_p_empty = '0;
    logic [$clog2(DW):0]    a_fifo_r_count = '0;

    logic                   x_fifo_a_tfull = '0;
    logic                   x_fifo_p_tfull = '0;
    logic [$clog2(DW):0]    x_fifo_w_count = '0;
    logic                   x_fifo_a_empty = '0;
    logic                   x_fifo_p_empty = '0;
    logic [$clog2(DW):0]    x_fifo_r_count = '0;

    logic                   x_fifo_m_tready;

    bit wr_seq_stop;
    logic wr_tvalid = '0;
    bit rd_seq_stop;
    logic rd_tready = '0;

    task wr_sequence(input int unsigned K = 1, int unsigned LENGTH = 16, RANDOM = "No" );


        @(posedge c_fifo_w_clk_p) wr_tvalid = '1;

        repeat ( LENGTH ) begin
            
            if ( wr_seq_stop ) break;

            if ( RANDOM == "No" ) begin
                if ( K == 0 ) begin
                    @(posedge c_fifo_w_clk_p) wr_tvalid = '1;
                end else begin
                    @(posedge c_fifo_w_clk_p) wr_tvalid = '0;
                    @(posedge c_fifo_w_clk_p) wr_tvalid = '1;
                end
            end else if ( RANDOM == "Yes" ) begin 
                @(posedge c_fifo_w_clk_p) wr_tvalid = $urandom_range(0, 1);
            end

        end

        wr_tvalid = '0;

    endtask

    task rd_sequence(input int unsigned K = 1, int unsigned LENGTH = 16, RANDOM = "No" );

        @(posedge c_fifo_r_clk_p) rd_tready = '1;

        repeat ( LENGTH ) begin
            
            if ( rd_seq_stop ) break;

            if ( RANDOM == "No" ) begin
                if ( K == 0 ) begin
                    @(posedge c_fifo_r_clk_p) rd_tready = '1;
                end else begin
                    @(posedge c_fifo_r_clk_p) rd_tready = '0;
                    @(posedge c_fifo_r_clk_p) rd_tready = '1;
                end
            end else if ( RANDOM == "Yes" ) begin 
                @(posedge c_fifo_r_clk_p) rd_tready = $urandom_range(0, 1);
            end

        end

        rd_tready = '0;

    endtask

    initial begin
        #(300) wr_sequence(0, 1, "No");
        #(10*R_CLK_PRD) rd_sequence(0, 1, "No");
        #(10*W_CLK_PRD) wr_sequence(0, 1, "No");
        #(10*W_CLK_PRD) wr_sequence(0, FIFO_DEPTH, "No");
        #(10*W_CLK_PRD) wr_sequence(0, 1, "No");
        #(10*W_CLK_PRD) wr_sequence(0, 1, "No");
        #(10*R_CLK_PRD) rd_sequence(0, 1, "No");
        #(10*W_CLK_PRD) wr_sequence(0, 1, "No");
        #(10*R_CLK_PRD) rd_sequence(0, 1, "No");
        #(10*R_CLK_PRD) rd_sequence(0, FIFO_DEPTH, "No");
        #(10*R_CLK_PRD) rd_sequence(0, 1, "No");
        #(10*R_CLK_PRD) rd_sequence(0, 1, "No");
        #(10*W_CLK_PRD) wr_sequence(0, FIFO_DEPTH+2, "No");
        #(10*R_CLK_PRD) rd_sequence(0, FIFO_DEPTH+2, "No");
        #(90*W_CLK_PRD) fork 
                            wr_sequence(0, 1e+7, "Yes");
                            rd_sequence(0, 1e+7, "Yes");
                        join
    end

    always begin
        //w_fifo_m.tlast = '1;
        #(40*W_CLK_PRD) w_fifo_m.tlast = '1;
        #(1*W_CLK_PRD) w_fifo_m.tlast = '0;
    end

// write one packet
/*     initial begin
        wr_tvalid = '0;
        w_fifo_m.tlast = '0;
        #(1200)         wr_tvalid = '1;
        #(10*W_CLK_PRD) w_fifo_m.tlast = '1;
        #(1*W_CLK_PRD)  w_fifo_m.tlast = '0;       
                        wr_tvalid = '0;
    end */

    logic q_fifo_w_rst_n = '1;
    logic q_fifo_r_rst_n = '1;
    
    always @(posedge c_fifo_w_clk_p)
        q_fifo_w_rst_n <= w_fifo_a_rst_n;

    always @(posedge c_fifo_r_clk_p)
        q_fifo_r_rst_n <= ( DUAL_CLOCK == "True" ) ? w_fifo_r_rst_n : w_fifo_a_rst_n;

    if_axis #( .N ( DW/8 ) ) w_fifo_m ();
    if_axis #( .N ( DW/8 ) ) a_fifo_m ();
    if_axis #( .N ( DW/8 ) ) w_fifo_s ();
    if_axis #( .N ( DW/8 ) ) a_fifo_s ();
    if_axis #( .N ( DW/8 ) ) x_fifo_s ();

    initial begin
            a_fifo_m.tuser = '0;
            w_fifo_m.tdata = '0;
            w_fifo_m.tkeep = 0'b10;
        #(200)
            w_fifo_a_rst_n = '0;
        #(10)
            w_fifo_a_rst_n = '1;            
    end

    assign w_fifo_m.tvalid = wr_tvalid;
    assign w_fifo_s.tready = rd_tready;

    always @(posedge c_fifo_w_clk_p)
        w_fifo_m.tdata <= w_fifo_m.tdata + 1;

    always @(posedge c_fifo_w_clk_p) begin
        a_fifo_m.tvalid <= w_fifo_m.tvalid;
        a_fifo_m.tdata  <= w_fifo_m.tdata;
        a_fifo_m.tlast  <= w_fifo_m.tlast && w_fifo_m.tvalid;
        if ( a_fifo_m.tvalid && a_fifo_m.tready )
            a_fifo_m.tuser <= a_fifo_m.tuser + 1;
    end

    always @(posedge c_fifo_r_clk_p) begin
        a_fifo_s.tready <= w_fifo_s.tready;
        x_fifo_s.tready <= w_fifo_s.tready;
    end

    axis_fifo #(
        .DEPTH ( FIFO_DEPTH ),
        .PACKET_MODE ( PACKET_MODE ),
        .MEM_STYLE ( MEM_STYLE ),
        .DUAL_CLOCK ( DUAL_CLOCK ),
        .SYNC_STAGES ( SYNC_STAGES ),
        .RESET_SYNC ( RESET_SYNC ),
        .PROG_FULL ( PROG_FULL ),
        .PROG_EMPTY ( PROG_EMPTY ),
        //.PAYLOAD_MASK ( PAYLOAD_MASK ),
        .FEATURES ( FEATURES )
    ) UUT (
        .i_fifo_a_rst_n ( w_fifo_a_rst_n ),
        .s_axis_a_clk_p ( c_fifo_w_clk_p ),
        .m_axis_a_clk_p ( c_fifo_w_clk_p ),
        //.i_fifo_a_rst_n ( w_fifo_a_rst_n ),
        .s_axis ( a_fifo_m ),
        .m_axis ( a_fifo_s ),
        .o_fifo_a_tfull ( a_fifo_a_tfull ),
        .o_fifo_p_tfull ( a_fifo_p_tfull ),
        .o_fifo_w_count ( a_fifo_w_count ),
        .o_fifo_a_empty ( a_fifo_a_empty ),
        .o_fifo_p_empty ( a_fifo_p_empty ),
        .o_fifo_r_count ( a_fifo_r_count )
    );

    xpm_fifo_axis #(
        .CDC_SYNC_STAGES        ( SYNC_STAGES ),
        .CLOCKING_MODE          ( SYNC_FIFO ),
        .ECC_MODE               ( "no_ecc" ),
        .FIFO_DEPTH             ( FIFO_DEPTH ),
        .FIFO_MEMORY_TYPE       ( MEM_STYLE ),
        .PACKET_FIFO            ( PACKET_FIFO ),
        .PROG_EMPTY_THRESH      ( PROG_EMPTY ),
        .PROG_FULL_THRESH       ( PROG_FULL ),
        .RD_DATA_COUNT_WIDTH    ( 5 ),
        .RELATED_CLOCKS         ( 0 ),
        .TDATA_WIDTH            ( DW ),
        .TDEST_WIDTH            ( 1 ),
        .TID_WIDTH              ( 1 ),
        .TUSER_WIDTH            ( 1 ),
        .USE_ADV_FEATURES       ( "0F0F" ),
        .WR_DATA_COUNT_WIDTH    ( 5 )
    ) xpm_fifo_axis_inst (
        .dbiterr_axis         (  ),
        .sbiterr_axis         (  ),
        .injectdbiterr_axis   (  ),
        .injectsbiterr_axis   (  ),
        //.m_aclk               ( x_fifo_s.a_clk_p   ),
        .m_axis_tdata         ( x_fifo_s.tdata     ),
        .m_axis_tdest         ( x_fifo_s.tdest     ),
        .m_axis_tid           ( x_fifo_s.tid       ),
        .m_axis_tkeep         ( x_fifo_s.tkeep     ),
        .m_axis_tlast         ( x_fifo_s.tlast     ),
        .m_axis_tstrb         ( x_fifo_s.tstrb     ),
        .m_axis_tuser         ( x_fifo_s.tuser     ),
        .m_axis_tvalid        ( x_fifo_s.tvalid    ),
        .m_axis_tready        ( x_fifo_s.tready    ),
        //.s_aclk               ( a_fifo_m.a_clk_p   ),
        //.s_aresetn            ( a_fifo_m.s_rst_n   ),
        .s_axis_tready        ( x_fifo_m_tready    ),
        .s_axis_tdata         ( a_fifo_m.tdata     ),
        .s_axis_tdest         ( a_fifo_m.tdest     ),
        .s_axis_tid           ( a_fifo_m.tid       ),
        .s_axis_tkeep         ( a_fifo_m.tkeep     ),
        .s_axis_tlast         ( a_fifo_m.tlast     ),
        .s_axis_tstrb         ( a_fifo_m.tstrb     ),
        .s_axis_tuser         ( a_fifo_m.tuser     ),
        .s_axis_tvalid        ( a_fifo_m.tvalid    ),
        .almost_full_axis     ( x_fifo_a_tfull     ),
        .prog_full_axis       ( x_fifo_p_tfull     ),
        .wr_data_count_axis   ( x_fifo_w_count     ),
        .almost_empty_axis    ( x_fifo_a_empty     ),
        .prog_empty_axis      ( x_fifo_p_empty     ),
        .rd_data_count_axis   ( x_fifo_r_count     )
    );

/*     xi_fifo xi_fifo_inst (
        .s_aclk         ( a_fifo_m.a_clk_p ),
        .m_aclk         ( x_fifo_s.a_clk_p ),
        .s_aresetn      ( a_fifo_m.s_rst_n ),
        .s_axis_tvalid  ( a_fifo_m.tvalid ),
        .s_axis_tready  ( x_fifo_m_tready ),
        .s_axis_tdata   ( a_fifo_m.tdata ),
        .s_axis_tlast   ( a_fifo_m.tlast ),
        .m_axis_tvalid  ( x_fifo_s.tvalid ),
        .m_axis_tready  ( x_fifo_s.tready ),
        .m_axis_tdata   ( x_fifo_s.tdata ),
        .m_axis_tlast   ( x_fifo_s.tlast )
    ); */

    bit tb_check_t_valid = '1;
    bit tb_check_t_ready = '1;
    bit tb_check_t_value = '1;
    bit tb_check_a_tfull = '1;
    bit tb_check_a_empty = '1;

    always #(W_CLK_PRD/2.0) tb_check_t_valid = ( x_fifo_s.tvalid == a_fifo_s.tvalid ) ? '1 : '0;
    always #(W_CLK_PRD/2.0) tb_check_t_ready = ( x_fifo_m_tready == a_fifo_m.tready ) ? '1 : '0;
    always #(W_CLK_PRD/2.0) tb_check_t_value = ( x_fifo_s.tdata  == a_fifo_s.tdata  ) ? '1 : '0;
    always #(W_CLK_PRD/2.0) tb_check_a_tfull = ( x_fifo_a_tfull  == a_fifo_a_tfull  ) ? '1 : '0;
    always #(W_CLK_PRD/2.0) tb_check_a_empty = ( x_fifo_a_empty  == a_fifo_a_empty  ) ? '1 : '0;

    always #(W_CLK_PRD/2.0) c_fifo_w_clk_p++;
    always #(R_CLK_PRD/2.0) c_fifo_r_clk_p++;

endmodule