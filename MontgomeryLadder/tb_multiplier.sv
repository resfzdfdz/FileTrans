

//~ `New testbench

module tb_multiplier;

// square Parameters
parameter PERIOD        = 10;
parameter NUM_ELEMENTS  = 17;
parameter BIT_LEN       = 17;
parameter WORD_LEN      = 16;
parameter NUM_ELEMENTS_OUT = 256+256+18+18;

// square Inputs
logic [BIT_LEN-1:0] A[NUM_ELEMENTS];
logic [BIT_LEN-1:0] B[NUM_ELEMENTS];

logic [NUM_ELEMENTS*WORD_LEN-1:0] A_p;
logic [NUM_ELEMENTS*WORD_LEN-1:0] B_p;

// square Outputs
logic [BIT_LEN-1:0] S[NUM_ELEMENTS*2+1];
logic [NUM_ELEMENTS_OUT-1:0] actual_result       ;
logic [NUM_ELEMENTS_OUT-1:0] expect_result       ;

logic [NUM_ELEMENTS*2:0][WORD_LEN-1:0] S_t;
logic [NUM_ELEMENTS*2:0][WORD_LEN-1:0] C_t;



logic clk = 0;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end




assign actual_result = S_t + {C_t<<WORD_LEN};

assign expect_result =A_p * B_p;

always@(posedge clk) begin
    A_p <= {$random, $random, $random, $random, $random, $random, $random, $random, $random,$random};
    B_p <= {$random, $random, $random, $random, $random, $random, $random, $random, $random,$random};
    $display("actual_result = %h\nexpect_result = %h\n", actual_result, expect_result);
end



genvar i;
generate
    for (i = 0; i < NUM_ELEMENTS; i++) begin
        assign A[i] = A_p[16*(i+1)-1:16*i];
        assign B[i] = B_p[16*(i+1)-1:16*i];
    end
endgenerate


initial
begin
    #(PERIOD*3)
    //$display("actual_result = %h\nexpect_result = %h\n", actual_result, expect_result);
    #(PERIOD*300)
    $stop;
end

genvar j;
generate
    for (j = 0; j < NUM_ELEMENTS*2+1; j++)begin
		assign S_t[j] = S[j][WORD_LEN-1:0];
		assign C_t[j] = {16'b0, S[j][WORD_LEN]};
    end
endgenerate

multiplier_256 
#(
    .NUM_ELEMENTS ( NUM_ELEMENTS ),
    .BIT_LEN      ( BIT_LEN      ),
    .WORD_LEN     ( WORD_LEN     ))
 u_multiplier_256 (
    .A(A),
    .B(B),
    .M(S)
);

endmodule
