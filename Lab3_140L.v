// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// -------------------------------------------------------------------- //           
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------

module Lab3_140L (
		  input wire 	    rst, // reset signal (active high)
		  input wire 	    clk, // global clock
		  input wire oneSecStrb,  	    
		  input 	    bu_rx_data_rdy, // data from the uart ready
		  input [7:0] 	    bu_rx_data, // data from the uart
		  output wire 	    L3_tx_data_rdy, // data to the alarm display
		  output wire [7:0] L3_tx_data,     // data to the alarm display
		  output [4:0] 	    L3_led,
		  output reg [6:0] 	    L3_segment1, // 1's seconds
		  output reg [6:0] 	    L3_segment2, // 10's seconds
		  output reg [6:0] 	    L3_segment3, // 1's minutes
		  output reg [6:0] 	    L3_segment4, // 10's minutes

		  output [3:0] 	    di_Mtens,
		  output [3:0] 	    di_Mones,
		  output [3:0] 	    di_Stens,
		  output wire [3:0] di_Sones,
		  output [3:0] 	    di_AMtens,
		  output [3:0] 	    di_AMones,
		  output [3:0] 	    di_AStens,
		  output [3:0] 	    di_ASones
		  );
		  wire alarmMatch;
		  wire loadtime;
		  wire loadalarm;
			didp didp(.di_Mtens(di_Mtens), .di_Mones(di_Mones), .di_Stens(di_Stens), .di_Sones(di_Sones),
		 	.di_AMtens(di_AMtens), .di_AMones(di_AMones),.di_AStens(di_AStens), .di_ASones(di_ASones), 
			.did_alarmMatch(alarmMatch), .L3_led(L3_led), .bu_rx_data(bu_rx_data), 
			.dicLdMtens(0), .dicLdMones(0), .dicLdStens(0), .dicLdSones(0), 
			.dicLdAMtens(0), .dicLdAMones(0), .dicLdAStens(0), .dicLdASones(0), 
			.dicRun(clk), .oneSecStrb(oneSecStrb), .rst(rst), .clk(clk));

endmodule // Lab3_140L


//
//
// sample interface for clock datpath
//
module didp (
	     output [3:0] di_Mtens, // current 10's minutes
	     output [3:0] di_Mones, // current 1's minutes
	     output [3:0] di_Stens, // current 10's second
	     output [3:0] di_Sones, // current 1's second

	     output [3:0] di_AMtens, // current alarm 10's minutes
	     output [3:0] di_AMones, // current alarm 1's minutes
	     output [3:0] di_AStens, // current alarm 10's second
	     output [3:0] di_ASones, // current alarm 1's second

	     output wire  did_alarmMatch, // one cydie alarm match (raw signal, unqualified)

	     output [4:0] L3_led,

	     input [7:0]  bu_rx_data,
	     input 	  dicLdMtens, // load 10's minute
	     input 	  dicLdMones, // load 1's minute
	     input 	  dicLdStens, // load 10's second
	     input 	  dicLdSones, // load 1's second
	     
	     input 	  dicLdAMtens, // load alarm 10's minute
	     input 	  dicLdAMones, // load alarm 1's minute
	     input 	  dicLdAStens, // load alarm 10's second
	     input 	  dicLdASones, // load alarm 1's second
	     input 	  dicRun, //clock should run 	  
	     input 	  oneSecStrb, // one cycle strobe
	     input 	  rst,
	     input 	  clk 	  
	     );

		 wire [3:0] reset;
		 
	   countrce countrce1(.q(di_Sones), .d(0), .ld(dicLdSones), .ce(1), .rst(reset[0]), .clk(clk));
		 countrce countrce2(.q(di_Stens), .d(0), .ld(dicLdStens), .ce(1), .rst(reset[1]), .clk(clk));
		 countrce countrce3(.q(di_Mones), .d(0), .ld(dicLdMones), .ce(1), .rst(reset[2]), .clk(clk));
		 countrce countrce4(.q(di_Mtens), .d(0), .ld(dicLdMtens), .ce(1), .rst(reset[3]), .clk(clk));
		 assign reset[0] = ((di_Sones == 4'b1001) || rst) ? 1'b1 : 1'b0;
		 assign reset[1] = (((di_Stens == 4'b0101) && (di_Sones == 4'b1001)) || rst) ? 1'b1 : 1'b0;
		 assign reset[2] = (((di_Mones == 4'b1001) && (di_Stens == 4'b0101) && (di_Sones == 4'b1001)) || rst) ? 1'b1 : 1'b0;
		 assign reset[3] = (((di_Mtens == 4'b0101) && (di_Mones == 4'b1001) && (di_Stens == 4'b0101) && (di_Sones == 4'b1001)) || rst) ? 1'b1 : 1'b0;
		 

endmodule




//
//
// sample interface for clock control
//
module dictrl(
	      output 	  dicLdMtens, // load the 10's minutes
	      output 	  dicLdMones, // load the 1's minutes
	      output 	  dicLdStens, // load the 10's seconds
	      output 	  dicLdSones, // load the 1's seconds
	      output 	  dicLdAMtens, // load the alarm 10's minutes
	      output 	  dicLdAMones, // load the alarm 1's minutes
	      output 	  dicLdAStens, // load the alarm 10's seconds
	      output 	  dicLdASones, // load the alarm 1's seconds
	      output 	  dicRun, // clock should run

	      output wire dicAlarmIdle, // alarm is off
	      output wire dicAlarmArmed, // alarm is armed
	      output wire dicAlarmTrig, // alarm is triggered

	      input       did_alarmMatch, // raw alarm match

              input 	  bu_rx_data_rdy, // new data from uart rdy
              input [7:0] bu_rx_data, // new data from uart
              input 	  rst,
	      input 	  clk
	      );

		  parameter S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, S4 = 4'b0100, 
		  S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111, S8 = 4'b1000, S9 = 4'b1001, S10 = 4'b1010;

		  reg state;

		always @(bu_rx_data_rdy) begin
		end

		always @(posedge clk) begin
		  	if (rst) begin
			  state <= S0;
			end
			else begin
			case (state)
				S0: begin
				end
				S1: begin
				end
				S2: begin
				end
				S3: begin
				end
				S4: begin
				end
				S5: begin
				end
				S6: begin
				end
				S7: begin
				end
				S8: begin
				end
				S9: begin
				end
				S10: begin
				end
			endcase
		end
	end 
endmodule

