module modmul_shell
(
	input logic 		clk,
	input logic			rst,
	input logic [16:0] 	din1,
	input logic [16:0]	din2,
	input logic         sout,
	output logic [16:0]	dout
);

localparam BIT_LEN			=	17;
localparam NUM_ELEMENTS		=	17;

logic [BIT_LEN-1:0] A[NUM_ELEMENTS];
logic [BIT_LEN-1:0] B[NUM_ELEMENTS];
logic [BIT_LEN-1:0] C[NUM_ELEMENTS];

logic [BIT_LEN-1:0] A_reg[NUM_ELEMENTS];
logic [BIT_LEN-1:0] B_reg[NUM_ELEMENTS];
logic [BIT_LEN-1:0] C_reg[NUM_ELEMENTS];

modmul #(
    .NUM_ELEMENTS          	(	 	17		),
    .BIT_LEN               	(	 	17		),
    .WORD_LEN              	(	 	16		),	
	.REDUCT_SEGMENT			(	 	19		),
	.NONREDUCT_SEGMENT		(	 	16		)
	)	modmul (
	.A						(	A_reg		),		
	.B						(	B_reg		),		
	.C						(		C		)
);	



always_ff @(posedge clk)
begin
	if (rst)
		for (int i = 0; i < NUM_ELEMENTS; i++) begin
			A_reg[i] <= 0;
			B_reg[i] <= 0;
		end
	else
		for (int i = 0; i < NUM_ELEMENTS; i++) begin
			if (i == 0) begin
				A_reg[i] <= din1;
				B_reg[i] <= din2;
				end
			else begin
				A_reg[i] <= A_reg[i-1];
				B_reg[i] <= B_reg[i-1];
				end
		end
end
		
always_ff @(posedge clk)
begin
	if (rst)
		for (int i = 0; i < NUM_ELEMENTS; i++) begin
			C_reg[i] <= 0;
		end
	else
	    if (sout)
	        for (int i = 0; i < NUM_ELEMENTS; i++) begin
			    C_reg[i] <= C[i];
		    end
		else
            for (int i = 0; i < NUM_ELEMENTS; i++) begin
                if (i == 0)
                    C_reg[i] <= C_reg[NUM_ELEMENTS-1];
                else
                    C_reg[i] <= C_reg[i-1];
            end
end

assign dout = C_reg[0];

endmodule