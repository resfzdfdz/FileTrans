module multiplier_256
#(
    parameter NUM_ELEMENTS          = 17,
    parameter BIT_LEN               = 17,
    parameter WORD_LEN              = 16
)
(
    input logic [BIT_LEN-1:0] A[NUM_ELEMENTS],
    input logic [BIT_LEN-1:0] B[NUM_ELEMENTS],

    output logic [BIT_LEN-1:0] M[NUM_ELEMENTS*2+1]
);

    localparam EXTRA_BIT = $clog2(NUM_ELEMENTS)+2;

    logic [NUM_ELEMENTS-1:0][BIT_LEN*2-1:0]  u_da0_out[NUM_ELEMENTS];

    genvar i,j;
	generate
	    for(i = 0; i < NUM_ELEMENTS; i = i + 1)begin:dsp_array_i
	        for(j = 0; j < NUM_ELEMENTS; j = j + 1)begin:dsp_array_j
	                dsp_multiplier #(.A_BIT_LEN(BIT_LEN), 
                                     .B_BIT_LEN(BIT_LEN)) 
                    u_dsp_multiplier(
                                .A(A[i][BIT_LEN-1:0]),
                                .B(B[j][BIT_LEN-1:0]),
                                .P(u_da0_out[i][j])
                                );
	        end
	    end
	endgenerate


    // format u_da0_out
    logic [NUM_ELEMENTS-1:0][WORD_LEN-1:0] u_da0_temp0[NUM_ELEMENTS];
    logic [NUM_ELEMENTS-1:0][WORD_LEN-1:0] u_da0_temp1[NUM_ELEMENTS];
    //logic [U0_NUM_ELEMENTS-1:0][U0_MUL_OUT_BIT_LEN-2*WORD_LEN-1:0] temp2[U0_NUM_ELEMENTS];
    logic [NUM_ELEMENTS-1:0][2*(BIT_LEN - WORD_LEN)-1:0] u_da0_temp2[NUM_ELEMENTS];

    always_comb begin
        for (int i = 0; i < NUM_ELEMENTS; i++) begin
            for (int j = 0; j < NUM_ELEMENTS; j++) begin
                u_da0_temp0[i][j] = u_da0_out[i][j][WORD_LEN-1:0];
                u_da0_temp1[i][j] = u_da0_out[i][j][WORD_LEN*2-1:WORD_LEN];
                u_da0_temp2[i][j] = {u_da0_out[i][j][BIT_LEN*2-1:WORD_LEN*2]};
            end
        end
    end

    logic [WORD_LEN+EXTRA_BIT-1:0]              sum_temp0[NUM_ELEMENTS*2-1];
    logic [WORD_LEN+EXTRA_BIT-1:0]              sum_temp1[NUM_ELEMENTS*2-1];
    logic [2*(BIT_LEN-WORD_LEN)+EXTRA_BIT-1:0]  sum_temp2[NUM_ELEMENTS*2-1];

    always_comb begin
        for (int c = 0; c < NUM_ELEMENTS*2-1; c++) begin
            if (c < NUM_ELEMENTS) begin
                for (int i = 0; i < c+1; i++) begin
                    if (i == 0) begin
                        sum_temp0[c] = u_da0_temp0[i][c-i];
                        sum_temp1[c] = u_da0_temp1[i][c-i];
                        sum_temp2[c] = u_da0_temp2[i][c-i];
                    end else begin
                        sum_temp0[c] = sum_temp0[c] + u_da0_temp0[i][c-i];
                        sum_temp1[c] = sum_temp1[c] + u_da0_temp1[i][c-i];
                        sum_temp2[c] = sum_temp2[c] + u_da0_temp2[i][c-i];
                    end
                end
            end else begin
                for (int j = NUM_ELEMENTS-1; j > c-NUM_ELEMENTS; j--) begin
                    if (j == NUM_ELEMENTS-1) begin
                        sum_temp0[c] = u_da0_temp0[j][c-j];
                        sum_temp1[c] = u_da0_temp1[j][c-j];
                        sum_temp2[c] = u_da0_temp2[j][c-j];
                    end else begin
                        sum_temp0[c] = sum_temp0[c] + u_da0_temp0[j][c-j];
                        sum_temp1[c] = sum_temp1[c] + u_da0_temp1[j][c-j];
                        sum_temp2[c] = sum_temp2[c] + u_da0_temp2[j][c-j];
                    end
                end
            end
        end
    end

    logic [WORD_LEN+EXTRA_BIT+1:0]  mid_sum[NUM_ELEMENTS*2+1];

    always_comb begin
        for (int i = 0; i < NUM_ELEMENTS*2+1; i++) begin
            if (i == 0) begin
                mid_sum[i] = sum_temp0[0];
            end else if (i == 1) begin
                mid_sum[i] = sum_temp0[1] + sum_temp1[0];
            end else if (i == NUM_ELEMENTS*2-1) begin
                mid_sum[i] = sum_temp1[NUM_ELEMENTS*2-2] + sum_temp2[NUM_ELEMENTS*2-3];
            end else if (i == NUM_ELEMENTS*2) begin
                mid_sum[i] = sum_temp2[NUM_ELEMENTS*2-2];
            end else begin
                mid_sum[i] =  sum_temp0[i] + sum_temp1[i-1] + sum_temp2[i-2];
            end
        end
    end


    always_comb begin
        for (int i = 0; i < NUM_ELEMENTS*2+1; i++) begin
            if (i == 0) begin
                M[i] = mid_sum[i];
            end else begin
                M[i] = mid_sum[i][WORD_LEN-1:0] + mid_sum[i-1][WORD_LEN+EXTRA_BIT+1:WORD_LEN];
            end
        end
    end
    


endmodule



module dsp_multiplier
   #(
    parameter int A_BIT_LEN       = 17,
    parameter int B_BIT_LEN       = 17,
    parameter int MUL_OUT_BIT_LEN = A_BIT_LEN + B_BIT_LEN
    )
   (
    input  logic [A_BIT_LEN-1:0]       A,
    input  logic [B_BIT_LEN-1:0]       B,
    output logic [MUL_OUT_BIT_LEN-1:0] P
   );

    always_comb begin
        P[MUL_OUT_BIT_LEN-1:0] = A[A_BIT_LEN-1:0] * B[B_BIT_LEN-1:0];
    end
endmodule


