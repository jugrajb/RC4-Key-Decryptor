
module shuffle_mem(clk, start, secret_key, reset, s_done, s_q, s_address, s_data, s_wren);
    input logic clk, start, reset;
    input logic [7:0] s_q;
    input logic [23:0] secret_key;

    output logic s_done, s_wren;
    output logic [7:0] s_address, s_data;

    //STATE DEFINATIONS
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
    

    logic [6:0] state = IDLE;

    logic [7:0] i = 8'b0;
    logic [7:0] j = 8'b0;

    logic [7:0] mem_data_i= 8'b0;
    logic [7:0] mem_data_j= 8'b0;
    logic [1:0] i_mod_key_len = 2'b0;
    logic [7:0] sec_data;

    always_ff @(posedge clk, posedge reset) begin
        if(reset) state <= IDLE;
        else begin
            case(state) 
                IDLE:       begin
                                if(start) state <= START;
                                else state <= IDLE;
                            end
                START:      state <= READ_I;
                READ_I:     state <= HOLD_I_R;
                HOLD_I_R:   state <= SAVE_I;
                SAVE_I:     state <= LOAD_SCKEY;
                LOAD_SCKEY: state <= CALC_J;
                CALC_J:     state <= READ_J;
                READ_J:     state <= HOLD_J_R;
                HOLD_J_R:   state <= SAVE_J;
                SAVE_J:     state <= WRITE_J;
                WRITE_J:    state <= WRITE_I;
                WRITE_I:    state <= CHECK_DONE;
                CHECK_DONE: begin
                                if(i == 8'hFF) state <= DONE;
                                else state <= INC_COUNT;
                            end
                INC_COUNT:  state <= START;
                DONE:       state <= DONE;
                default:    state <= IDLE;
            endcase
        end
    end

    assign s_done = state[6];

    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin 
            i <= 8'b0;
            j <= 8'b0;
            mem_data_i <= 8'b0;
            mem_data_j <= 8'b0;
            i_mod_key_len <= 2'b0;
        end else begin
            case(state)
                READ_I:     s_address <= i;
                SAVE_I:     begin
                                s_address <= i;
                                mem_data_i <= s_q;
                            end
                LOAD_SCKEY: begin 
                                case(i_mod_key_len)
                                    2'b00: sec_data <= secret_key[23:16];
                                    2'b01: sec_data <= secret_key[15:8];
                                    2'b10: sec_data <= secret_key[7:0];
                                    default: sec_data <= 8'h0;
                                endcase   
                            end 
                CALC_J:     j <= mem_data_i + sec_data + j;
                READ_J:     s_address <= j;
                SAVE_J:     begin
                                s_address <= j;
                                mem_data_j <= s_q;
                            end  
                WRITE_J:    begin
                                s_address <= i;
                                s_data <= mem_data_j;
                            end
                WRITE_I:    begin
                                s_address <= j;
                                s_data <= mem_data_i;
                            end
                INC_COUNT:  begin
                                i <= i + 1'b1;
                                case(i_mod_key_len)
                                    2'b00: i_mod_key_len <= 2'b01;
                                    2'b01: i_mod_key_len <= 2'b10;
                                    2'b10: i_mod_key_len <= 2'b00;
                                    default: i_mod_key_len <= 2'b00;
                                endcase
                            end
                default:    s_address <= s_address;
            endcase
        end
        
    end

    always_ff @(posedge clk) begin
        s_wren <= state[5];
    end

endmodule