module decrypt_tb();
    reg clk, reset, start, err;
    reg [7:0] dm_w_q, dm_en_r_q;

    wire dm_done, dm_invalid, dm_w_wren, dm_dc_wren;
    wire [7:0] dm_w_address, dm_w_data, dm_en_r_address, dm_dc_address, dm_dc_data;

    decrypt_msg dut(
        .clk(clk),
        .reset(reset),
        .start(start),
        .dm_w_q(dm_w_q),
        .dm_en_r_q(dm_en_r_q),
        .dm_done(dm_done),
        .dm_invalid(dm_invalid),
        .dm_w_wren(dm_w_wren),
        .dm_dc_wren(dm_dc_wren),
        .dm_dc_address(dm_dc_address),
        .dm_dc_data(dm_dc_data)
    );

    parameter [8:0] IDLE        = 9'b0000_00001;
    parameter [8:0] INC_I       = 9'b0000_00010;
    parameter [8:0] LOAD_I      = 9'b0000_00011;
    parameter [8:0] READ_I      = 9'b0000_00100;
    parameter [8:0] SAVE_I      = 9'b0000_00101;
    parameter [8:0] CALC_J      = 9'b0000_00110;
    parameter [8:0] LOAD_J      = 9'b0000_00111;
    parameter [8:0] READ_J      = 9'b0000_01000;
    parameter [8:0] SAVE_J      = 9'b0000_01001;
    parameter [8:0] WRITE_I     = 9'b0010_01010;
    parameter [8:0] WRITE_J     = 9'b0010_01011;
    parameter [8:0] CALC_F_IND  = 9'b0000_01110;
    parameter [8:0] LOAD_F_IND  = 9'b0000_01111;
    parameter [8:0] READ_F_IND  = 9'b0000_10000;
    parameter [8:0] LOAD_ENC    = 9'b0000_10001;
    parameter [8:0] READ_ENC    = 9'b0000_10010;
    parameter [8:0] CHK_DC_DATA = 9'b0000_10011;
    parameter [8:0] WRITE_DC    = 9'b0001_10100;
    parameter [8:0] CHK_DONE    = 9'b0000_10101;
    parameter [8:0] INC_K       = 9'b0000_10110;
    parameter [8:0] DONE        = 9'b0100_10111;
    parameter [8:0] INVALID_D   = 9'b1000_11000;
    parameter [8:0] XOR_F_EN    = 9'b0000_11001;

    task checkState;
        input [8:0] expected_state;

        begin
            if(decrypt_tb.dut.state !== expected_state) begin
                $display("Error ** state is %b, expected %b",
                decrypt_tb.dut.state, expected_state );
            err = 1'b1;
            end
        end
    endtask

        initial begin 
        clk = 0; #2;
        forever begin
        clk = 1; #2;
        clk = 0; #2;
        end
    end

    initial begin
        err = 1'b0; reset = 1'b0; start = 1'b1;

        checkState(IDLE); #4;
        $display("Checking State"); 
        checkState(INC_I);#4
        $diplay("Check State"); 
        checkState(LOAD_I);#4
        $diplay("Check State"); 
        checkState(READ_I);#4
        $diplay("Check State"); 
        checkState(SAVE_I);#4
        $diplay("Check State"); 
        checkState(CALC_J);#4
        $diplay("Check State"); 
        checkState(LOAD_J);#4
        $diplay("Check State"); 
        checkState(READ_J);#4
        $diplay("Check State"); 
        checkState(SAVE_J);#4
        $diplay("Check State"); 
        checkState(WRITE_I);#4
        $diplay("Check State"); 
        checkState(WRITE_J);#4
        $diplay("Check State"); 
        checkState(LOAD_F_IND);#4
        $diplay("Check State"); 
        checkState(READ_F_IND);#4
        $diplay("Check State"); 
        checkState(LOAD_ENC);#4
        $diplay("Check State"); 
        checkState(READ_ENC);#4
        $diplay("Check State"); 
        checkState(XOR_F_EN);#4
        $diplay("Check State"); 
        checkState(CHK_DC_DATA);#4
        $diplay("Check State"); 
        checkState(WRITE_DC);#4
        $diplay("Check State"); 
        checkState(CHK_DONE);#4

       

        if(~err) $display("All tests passed");
        $stop;
    end
endmodule

