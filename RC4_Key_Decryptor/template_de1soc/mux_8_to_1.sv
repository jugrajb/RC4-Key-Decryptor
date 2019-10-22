module mux_8_to_1 #(
    parameter input_size = 8
)(
    input logic [input_size-1:0] in1, in2, in3, in4, in5, in6, in7, in8, select,
    output logic [input_size-1:0] out1
);
    always_comb begin
        casex(select) 
            8'b0000_0000: out1 <= in1;
            8'b0000_0001: out1 <= in2;
            8'b0000_001x: out1 <= in3;
            8'b0000_01xx: out1 <= in4;
            8'b0000_1xxx: out1 <= in5;
            8'b0001_xxxx: out1 <= in6;
            8'b001x_xxxx: out1 <= in7;
            8'b01xx_xxxx: out1 <= in8;
            default: out1 <= in1;
        endcase
    end
endmodule