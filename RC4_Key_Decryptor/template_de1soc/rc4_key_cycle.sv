module rc4_key_cycle #(
	parameter [23:0] counter_start = 24'b0,
    parameter [23:0] counter_end = 24'h7FFFFF
)
(   
    clk, reset, start, enable,
    dc_done, dc_invalid, 
    sc_key, reset_decrypt, start_decrypt, no_sol
);

    input logic clk, reset, start, dc_done, dc_invalid, enable;
    output logic [23:0] sc_key;
    output logic reset_decrypt, start_decrypt, no_sol;

    logic [23:0] key_count = counter_start;

    //States
    parameter [6:0] IDLE            = 7'b000_0000;
    parameter [6:0] RESET_MANUAL    = 7'b001_0001;
    parameter [6:0] WAIT_DECRYPT    = 7'b010_0010;
    parameter [6:0] KEY_INC         = 7'b000_0011;
    parameter [6:0] RESET_DECRPYT   = 7'b001_0100;
    parameter [6:0] DONE            = 7'b000_0101;
    parameter [6:0] CHK_KEY         = 7'b000_0111;
    parameter [6:0] NO_SOL          = 7'b100_1000;

    logic [6:0] state;

    always_ff @(posedge clk, posedge reset) begin
        if(reset) state <= RESET_MANUAL;
        else if(enable) state <= DONE;
        else begin
            case(state)
                IDLE:           begin
                                    if(start) state <= WAIT_DECRYPT;
                                    else state <= IDLE;
                                end
                WAIT_DECRYPT:   begin
                                    if(dc_done) state <= DONE;
                                    else if(dc_invalid) state <= KEY_INC;
                                    else state <= WAIT_DECRYPT;
                                end
                CHK_KEY:        begin
                                    if(key_count >= counter_end) state <= NO_SOL;
                                    else state <= KEY_INC;
                                end
                KEY_INC:        state <= RESET_DECRPYT;
                RESET_DECRPYT:  state <= WAIT_DECRYPT;
                RESET_MANUAL:   state <= IDLE;
                DONE:           state <= DONE;
                NO_SOL:         state <= NO_SOL;
                default:        state <= IDLE;
            endcase
        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if(reset) key_count <= counter_start;
        else begin
            case(state)
                KEY_INC: key_count <= key_count + 1'b1;
                default: key_count <= key_count;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        sc_key <= key_count;
        reset_decrypt <= state[4];
        start_decrypt <= state[5];
        no_sol <= state[6];
    end

endmodule