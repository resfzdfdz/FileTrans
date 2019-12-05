/*******************************************************************************
  Copyright 2019 Xi'an Jiaotong University

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*******************************************************************************/

module tb_PAD;

parameter NUM_ELEMENTS          = 17;
parameter BIT_LEN               = 17;
parameter WORD_LEN              = 16;
parameter DATA_LEN				= 256;
localparam p = 256'hfffffffeffffffffffffffffffffffffffffffff00000000ffffffffffffffff;

logic clk = 0;
logic rst = 0;
logic start = 0;
logic finish;
logic [DATA_LEN-1:0] k; 
logic [DATA_LEN-1:0] x1; 
logic [DATA_LEN-1:0] y1;
logic [DATA_LEN-1:0] x3;
logic [DATA_LEN-1:0] z31;
logic [DATA_LEN-1:0] y3;
logic [DATA_LEN-1:0] z32;

PAD_fsm #(
	.NUM_ELEMENTS          	(	NUM_ELEMENTS	),
    .BIT_LEN               	(	BIT_LEN			),
    .WORD_LEN              	(	WORD_LEN		),
	.DATA_LEN				(	DATA_LEN		)
	) PAD_fsm (
	.clk					(		clk			),
	.rst					(		rst			),
	.start					(		start		),
	.k						(		k			),
	.x1						(		x1			),
	.y1						(		y1			),
	.x3						(		x3			),
	.z31					(		z31			),
	.y3						(		y3			),
	.z32					(		z32			),
	.finish					(		finish		)
);

//  Clock 
localparam HP = 5;
initial begin
	clk = 0;
	forever #(HP) clk = ~clk;
end

//  Reset
initial begin
	rst = 1;
	#(HP*2) rst = 0;
end

//  Basic Point G = (px, py)
initial begin
	x1 = 256'h32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7;
	y1 = 256'hBC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0;
end

// Uncomment Here to enable random k simulation
/*//  Random k
logic [DATA_LEN-1:0] dk;
always @(posedge clk)
begin
	if (rst)
		dk <= 256'd20;
	else
		if (finish)
			dk <= {$random, $random, $random, $random, $random, $random, $random, $random};
		else
			dk <= dk;
end
assign k = dk;

//  Start 
always @(posedge clk)
begin
	if (rst)
		start <= 0;
	else
		if (finish) begin
			start <= 0;
			#(HP * 5) start <= 1;
			end
		else
			start <= 1;
end

always @(posedge finish)
begin
	$display("k 	= %x", k);
	$display("x3 	= %x", x3);
	$display("z31 	= %x", z31);
	$display("y3 	= %x", y3);
	$display("z32 	= %x\n", z32);
end */

/* function [290:0] redunt2int;
	input [BIT_LEN-1:0] din[NUM_ELEMENTS];
	begin
		redunt2int = 0;
		for (int i = 0; i < NUM_ELEMENTS; i++) begin
			redunt2int = redunt2int + (din[i] << (16*i));
		end
		redunt2int = redunt2int % p;
	end
endfunction

task print_result;
	input [BIT_LEN-1:0] din[NUM_ELEMENTS];
	logic [290:0] result;
	begin
		result = redunt2int(din);
		$display("%x\n", result);
	end
endtask */

integer test_pattern;
logic [DATA_LEN-1:0] k_py;
logic [DATA_LEN-1:0] x3_py;
logic [DATA_LEN-1:0] z31_py;
logic [DATA_LEN-1:0] y3_py;
logic [DATA_LEN-1:0] z32_py;

int i;

task test;
	input logic [DATA_LEN-1:0] k_py;
	input logic [DATA_LEN-1:0] x3_py;
	input logic [DATA_LEN-1:0] z31_py;
	input logic [DATA_LEN-1:0] y3_py;
	input logic [DATA_LEN-1:0] z32_py;
	
	time start_time;
	time finish_time;
	reg [127:0] latency;
	
	logic [DATA_LEN-1:0] x3_res;
	logic [DATA_LEN-1:0] z31_res;
	logic [DATA_LEN-1:0] y3_res;
	logic [DATA_LEN-1:0] z32_res;
	
	begin
		@(posedge clk)
			begin
				k 			= 	k_py;
			end
			
		@(posedge clk)
			begin
				start		=	1'b1;
				start_time 	= 	$time;
			end
		
		@(negedge finish)
			begin
				x3_res 		=	x3;
				z31_res		=	z31;
				y3_res		=	y3;
				z32_res		=	z32;
				start		=	0;
				finish_time	=	$time;
			end
			
		latency = finish_time - start_time;
		
		if ( (x3_res != x3_py) || (z31_res != z31_py) || (y3_res != y3_py) || (z32_res != z32_py) )
				begin
					$display("Error! time =", $time);
					
					$display("k   	  = %x", k);
					$display("x3_res  = %x", x3_res);
					$display("z31_res = %x", z31_res);
					$display("y3_res  = %x", y3_res);
					$display("z32_res = %x\n", z32_res);
					
					$display("k_py    = %x", k_py);
					$display("x3_py	  = %x", x3_py);
					$display("z31_py  = %x", z31_py);
					$display("y3_py	  = %x", y3_py);
					$display("z32_py  = %x", z32_py);
				end
 			else
				begin
					$display("Correct!, time =", $time);
//  Uncomment Here to enable correct result display					
/* 					$display("k   	  = %x", k);
					$display("x3_res  = %x", x3_res);
					$display("z31_res = %x", z31_res);
					$display("y3_res  = %x", y3_res);
					$display("z32_res = %x\n", z32_res);
					
					$display("k_py    = %x", k_py);
					$display("x3_py	  = %x", x3_py);
					$display("z31_py  = %x", z31_py);
					$display("y3_py	  = %x", y3_py);
					$display("z32_py  = %x", z32_py); */
				end
				
		// $display("Latency = %d\n", (latency) / (2 * HP) );
	end
endtask

task read_data;
	begin
		$fscanf(test_pattern, "%h/n", k_py);
		$fscanf(test_pattern, "%h/n", x3_py);
		$fscanf(test_pattern, "%h/n", z31_py);
		$fscanf(test_pattern, "%h/n", y3_py);
		$fscanf(test_pattern, "%h/n", z32_py);
	end
endtask	

task test_wrapper;
	begin
		read_data();
		test(k_py, x3_py, z31_py, y3_py, z32_py);
	end
endtask

// Uncomment Here to enable auto simulation
initial begin : test_pattern_from_python
	test_pattern = $fopen("Test_Pattern.txt", "r");
	if (test_pattern == 0)
		disable test_pattern_from_python;
	else
		begin
			while ( !$feof(test_pattern) )
				test_wrapper();
			$finish;
		end
end

// Uncomment Here to enable behavior simulation
/* initial begin
	k = 256'h54a831eb99243e52259125d1c7c51054f9791ddce895f6b79eba303582471c70;
	#(HP*5) @(posedge clk)
	start = 1;
	@(posedge finish)
	start = 0;
end */

endmodule