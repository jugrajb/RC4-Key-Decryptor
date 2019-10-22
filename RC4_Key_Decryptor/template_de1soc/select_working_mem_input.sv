module select_working_mem_input(
    input logic clk,
    input logic load_done,
    input logic shuffle_done,
    input logic [7:0] l_address,
    input logic [7:0] l_data,
    input logic  l_wren,
    input logic [7:0] s_address,
    input logic [7:0] s_data,
    input logic s_wren,
    input logic [7:0] dm_address,
    input logic [7:0] dm_data,
    input logic dm_wren,
    output logic [7:0] out_address,
    output logic [7:0] out_data,
    output logic [7:0] out_wren
); 

    always_comb begin
        if(~load_done) begin
            out_address = l_address;
            out_data = l_data;
            out_wren = l_wren;
        end else if(~shuffle_done) begin
            out_address = s_address;
            out_data = s_data;
            out_wren = s_wren;
        end else begin
            out_address = dm_address;
            out_data = dm_data;
            out_wren = dm_wren;
        end
    end

endmodule