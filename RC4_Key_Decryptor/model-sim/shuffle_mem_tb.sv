module shuffle_mem_tb();
    reg clk, start, reset, err;
    reg [23:0] secret_key;
    wire [7:0] s_q;

    reg s_done, s_wren;
    reg [7:0] s_address, s_data;

    shuffle_mem dut(
        .clk(clk),
        .start(start),
        .reset(reset),
        .s_q(s_q),
        .s_wren(s_wren),
        .s_address(s_address),
        .s_data(s_data),
        .secret_key(secret_key),
        .s_done(s_done)
    );

    //State encodings
    parameter [6:0] IDLE        = 7'b00_00000;
    parameter [6:0] START       = 7'b00_00001;
    //===READ s[i] from memory and store value
    parameter [6:0] READ_I      = 7'b00_00010;
    parameter [6:0] HOLD_I_R    = 7'b00_00011;
    parameter [6:0] SAVE_I      = 7'b00_00100;
    //===LOAD v6lid portion of secret key
    parameter [6:0] LOAD_SCKEY  = 7'b00_00101;
    //===calcul6te j index
    parameter [6:0] CALC_J      = 7'b00_00110;
    //===READ s[j] from memory and store value
    parameter [6:0] READ_J      = 7'b00_00111;
    parameter [6:0] HOLD_J_R    = 7'b00_01000; 
    parameter [6:0] SAVE_J      = 7'b00_01001;
    //===Write s[j] @ index i
    parameter [6:0] WRITE_J     = 7'b01_01010;
    //===Write s[i] @index j
    parameter [6:0] WRITE_I     = 7'b01_01011;
    //==check if done or loop
    parameter [6:0] CHECK_DONE  = 7'b00_10100;
    parameter [6:0] INC_COUNT   = 7'b00_10101;
    parameter [6:0] DONE        = 7'b10_10110;

    task checkState;
        input [6:0] expected_state;
    
        begin
            if( shuffle_mem_tb.dut.state !== expected_state) begin
                $display("Error ** state is %b, expected %b",
                shuffle_mem_tb.dut.state, expected_state );
            err = 1'b1;
            end
        end
    endtask

    task checkMemData;
        input [7:0] expected_data;
        
        begin 
            if( shuffle_mem_tb.dut.s_data !== expected_data) begin
                $display("Error ** data is %b, expected %b",
                shuffle_mem_tb.dut.s_data, expected_data);
            err = 1'b1;
            end
        end
    endtask

    task checkMemAddress;
        input [7:0] expected_address;
        
        begin 
            if( shuffle_mem_tb.dut.s_address !== expected_address) begin
                $display("Error ** address is %b, expected %b",
                shuffle_mem_tb.dut.s_address, expected_address);
            err = 1'b1;
            end
        end
    endtask

    task checkMemWren;
        input expected_wren;

        begin
            if(shuffle_mem_tb.dut.s_wren !== s_wren) begin
            	$display("Error ** wren us %b, expected %b",
            	shuffle_mem_tb.dut.s_wren, expected_wren);
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
        secret_key = 24'h000249;

        //check-inital
        checkState(IDLE); #4;

        
        $display("Checking State");
        checkState(START); #4;

        
        $display("Checking State");
        checkState(READ_I); #4;

       
        $display("Checking State"); 
         checkState(HOLD_I_R); #4;

        
        $display("Checking State"); 
        checkState(SAVE_I); #4;

        
        $display("Checking State"); 
        checkState(LOAD_SCKEY); #4;

        
        $display("Checking State");
        checkState(CALC_J); #4;

        
        $display("Checking State");
        checkState(READ_J); #4;

        
        $display("Checking State");
        checkState(HOLD_J_R); #4;

        
        $display("Checking State");
        checkState(SAVE_J); #4;

        
        $display("Checking State"); 
        checkState(WRITE_J); #4;

        
        $display("Checking State"); 
        checkState(WRITE_I); #4;

        
        $display("Checking State"); 
        checkState(CHECK_DONE); #4;
        
        
        $display("Checking State"); 
        checkState(INC_COUNT); #4;

                $display("Checking State");
        checkState(START); #4;

        
        $display("Checking State");
        checkState(READ_I); #4;

       
        $display("Checking State"); 
         checkState(HOLD_I_R); #4;

        
        $display("Checking State"); 
        checkState(SAVE_I); #4;

        
        $display("Checking State"); 
        checkState(LOAD_SCKEY); #4;

        
        $display("Checking State");
        checkState(CALC_J); #4;

        
        $display("Checking State");
        checkState(READ_J); #4;

        
        $display("Checking State");
        checkState(HOLD_J_R); #4;

        
        $display("Checking State");
        checkState(SAVE_J); #4;

        
        $display("Checking State"); 
        checkState(WRITE_J); #4;

        
        $display("Checking State"); 
        checkState(WRITE_I); #4;

        
        $display("Checking State"); 
        checkState(CHECK_DONE); #4;
        
        
        $display("Checking State"); 
        checkState(DONE); #4;

        

        if(~err) $display("All tests passed");
        $stop;
    end 
endmodule