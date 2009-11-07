// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed into the Public Domain, for any use,
// without warranty, 2009 by Wilson Snyder.

//UNSUPtypedef reg [2:0] three_t;

module t (/*AUTOARG*/
   // Inputs
   clk
   );
   input clk;

   typedef reg [2:0] three_t; //UNSUP remove

   integer 	cyc=0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;

   // Take CRC data and apply to testblock inputs
   wire [2:0]  in = crc[2:0];

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   three_t		outna;			// From test of TestNonAnsi.v
   // End of automatics

   TestNonAnsi test (// Outputs
		     .out		(outna),
		     /*AUTOINST*/
		     // Inputs
		     .clk		(clk),
		     .in		(in));

//UNSUP
//   TestAnsi testa (// Outputs
//		  .out			(outa),
//		  /*AUTOINST*/
//		  // Inputs
//		  .clk			(clk),
//		  .in			(in));
   wire [2:0]  outa = outna;

   // Aggregate outputs into a single result vector
   wire [63:0] result = {57'h0, outna, 1'b0, outa};

   // Test loop
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d crc=%x result=%x\n",$time, cyc, crc, result);
`endif
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63]^crc[2]^crc[0]};
      sum <= result ^ {sum[62:0],sum[63]^sum[2]^sum[0]};
      if (cyc==0) begin
	 // Setup
	 crc <= 64'h5aef0c8d_d70a4497;
	 sum <= 64'h0;
      end
      else if (cyc<10) begin
	 sum <= 64'h0;
      end
      else if (cyc<90) begin
      end
      else if (cyc==99) begin
	 $write("[%0t] cyc==%0d crc=%x sum=%x\n",$time, cyc, crc, sum);
	 if (crc !== 64'hc77bb9b3784ea091) $stop;
	 // What checksum will we end up with (above print should match)
`define EXPECTED_SUM 64'h018decfea0a8828a
	 if (sum !== `EXPECTED_SUM) $stop;
	 $write("*-* All Finished *-*\n");
	 $finish;
      end
   end

endmodule

module TestNonAnsi (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, in
   );
   typedef reg [2:0] three_t;

   input clk;
   input three_t in;
   output three_t out;

   always @(posedge clk) begin
      out <= ~in;
   end
endmodule

`ifndef verilator //UNSUPPORTED
typedef reg [2:0] three_t;

module TestAnsi (
	     input clk,
	     input three_t in,
	     output three_t out
	     );
   always @(posedge clk) begin
      out <= ~in;
   end
endmodule

`endif

// Local Variables:
// verilog-typedef-regexp: "_t$"
// End:
