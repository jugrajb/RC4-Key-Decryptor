module load_mem(clk, reset, start, l_address, l_wren, l_data, l_done);
    input logic clk, reset, start;

    output logic l_done, l_wren;
    output logic [7:0] l_data, l_address;

    //States
    parameter [4:0] IDLE        = 5'b00_000;
    parameter [4:0] BEGIN_LOAD  = 5'b00_001;
    parameter [4:0] INC_COUNT   = 5'b00_010;
    parameter [4:0] LOAD_DATA   = 5'b01_011;
    parameter [4:0] WRITE_DATA  = 5'b01_100;
    parameter [4:0] CHECK_DONE  = 5'b00_101;
    parameter [4:0] LOAD_DONE   = 5'b10_110;

    logic [7:0] counter = 8'b0;
    logic [4:0] state= IDLE;

    always_ff @(posedge clk or posedge reset) begin
        if(reset) state <= IDLE;
        else begin
            case(state)
                IDLE:       begin
                                if(start) state <= BEGIN_LOAD;
                                else state <= IDLE;
                            end
                BEGIN_LOAD: state <= LOAD_DATA;
                LOAD_DATA:  state <= WRITE_DATA;
                WRITE_DATA: state <= CHECK_DONE;
                CHECK_DONE: begin
                                if(counter == 0) state <= LOAD_DONE;
                                else state <= INC_COUNT;
                            end
                INC_COUNT:  state <= BEGIN_LOAD;
                LOAD_DONE:  state <= LOAD_DONE;
                default:    state <= IDLE;
            endcase
        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if(reset) counter <= 8'b0;
        else begin
            case(state)
                LOAD_DATA: begin
                            l_address <= counter;
                            l_data <= counter;
                end
                INC_COUNT: counter <= counter + 1'b1;
                default:   counter <= counter;
				endcase
        end
    end

    assign l_wren = state[3];
    assign l_done = state[4];

endmodule