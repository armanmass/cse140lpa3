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
		    wire LdMtens, LdMones, LdStens, LdSones, LdAMtens,
	      		 LdAMones, LdAStens, LdASones, Run;
			wire loadalarm;

			wire idle, armed, trig, alarmMatch;
			reg [7:0] alarmchar;
			reg [7:0] min1,min2,sec1,sec2;
			reg [7:0] disp1,disp2,disp3,disp4;
		    
			wire [6:0] seg1, seg2, seg3, seg4;

			always @(*) begin
				L3_segment1 = seg1;
				L3_segment2 = seg2;
				L3_segment3 = seg3;
				L3_segment4 = seg4;

				disp1[7:4] = 4'b0011;
				disp2[7:4] = 4'b0011;
				disp3[7:4] = 4'b0011;
				disp4[7:4] = 4'b0011;
				disp1[3:0] = di_AMtens;
				disp2[3:0] = di_AMones;
				disp3[3:0] = di_AStens;
				disp4[3:0] = di_ASones;


				if(loadalarm) begin
					min1[7:4] = 4'b0011;
					min2[7:4] = 4'b0011;
					sec1[7:4] = 4'b0011;
					sec2[7:4] = 4'b0011;
					min1[3:0] = di_AMtens;
					min2[3:0] = di_AMones;
					sec1[3:0] = di_AStens;
					sec2[3:0] = di_ASones;
				end
				else begin
					min1[7:4] = 4'b0011;
					min2[7:4] = 4'b0011;
					sec1[7:4] = 4'b0011;
					sec2[7:4] = 4'b0011;
					min1[3:0] = di_Mtens;
					min2[3:0] = di_Mones;
					sec1[3:0] = di_Stens;
					sec2[3:0] = di_Sones;
				end
			end


			always @(posedge clk) begin
				if(idle)
					alarmchar = 8'b00101110;
				else if(armed)
					alarmchar = 8'b01100001;
				else if(trig)
					alarmchar = 8'b01010100;
				else
					alarmchar = 8'b00101110;
			end

			bcd2segment bcd2segment1(seg1, sec2, 1);
			bcd2segment bcd2segment2(seg2, sec1, 1);
			bcd2segment bcd2segment3(seg3, min2, 1);
			bcd2segment bcd2segment4(seg4, min1, 1);


			dispString dispString(.rdy(L3_tx_data_rdy), .dOut(L3_tx_data), .b0(min1), .b1(min2), .b2(8'b00111010), 
								  .b3(sec1), .b4(sec2), .b5(8'b00100000), .b6(alarmchar), .b7(8'h0d), .go(oneSecStrb), 
								  .rst(rst), .clk(clk));



			dictrl dictrl(.dicLdMtens(LdMtens), .dicLdMones(LdMones), .dicLdStens(LdStens), .dicLdSones(LdSones), 
			.dicLdAMtens(LdAMtens), .dicLdAMones(LdAMones), .dicLdAStens(LdAStens), .dicLdASones(LdASones), .dicRun(Run),
			.dicAlarmIdle(idle), .dicAlarmArmed(armed), .dicAlarmTrig(trig), .oneSecStrb(oneSecStrb), .did_alarmMatch(alarmMatch), 
			.bu_rx_data_rdy(bu_rx_data_rdy), .dataIn(bu_rx_data), .loadalarm(loadalarm), .rst(rst), .clk(clk));

			didp didp(.di_Mtens(di_Mtens), .di_Mones(di_Mones), .di_Stens(di_Stens), .di_Sones(di_Sones),
		 	.di_AMtens(di_AMtens), .di_AMones(di_AMones),.di_AStens(di_AStens), .di_ASones(di_ASones), 
			.did_alarmMatch(alarmMatch), .L3_led(L3_led), .bu_rx_data(bu_rx_data), 
			.dicLdMtens(LdMtens), .dicLdMones(LdMones), .dicLdStens(LdStens), .dicLdSones(LdSones), 
			.dicLdAMtens(LdAMtens), .dicLdAMones(LdAMones), .dicLdAStens(LdAStens), .dicLdASones(LdASones), 
			.dicRun(Run), .oneSecStrb(oneSecStrb), .rst(rst), .clk(clk));

endmodule // Lab3_140L


//
//
// sample interface for clock datpath
//
module didp (
	     output reg [3:0] di_Mtens, // current 10's minutes
	     output reg [3:0] di_Mones, // current 1's minutes
	     output reg [3:0] di_Stens, // current 10's second
	     output reg [3:0] di_Sones, // current 1's second

	     output reg [3:0] di_AMtens, // current alarm 10's minutes
	     output reg [3:0] di_AMones, // current alarm 1's minutes
	     output reg [3:0] di_AStens, // current alarm 10's second
	     output reg [3:0] di_ASones, // current alarm 1's second

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

		 reg [3:0] reset;
		 reg [3:0] ce;
		 wire [3:0] Mtens, Mones, Stens, Sones,
		 			AMtens, AMones, AStens, ASones;

		reg alarmmatching;
		 

		 always @(*) begin
		 	di_Mtens = Mtens;
		  	di_Mones = Mones;
		  	di_Stens = Stens;
		  	di_Sones = Sones;

			di_AMtens = AMtens;
		  	di_AMones = AMones;
		  	di_AStens = AStens;
		  	di_ASones = ASones;
		 end

		 always @(posedge clk) begin
			if(rst) begin
				ce[0] = 1'b0;
				ce[1] = 1'b0;
				ce[2] = 1'b0;
				ce[3] = 1'b0;
				
				reset[0] = 1'b1;
		 		reset[1] = 1'b1;
		 		reset[2] = 1'b1;
		 		reset[3] = 1'b1;
			end
		 	else if(oneSecStrb) begin
				ce[0] = (1 && dicRun);
				ce[1] = (Sones == 4'b1001) ? 1'b1 : 1'b0;
				ce[2] = ((Stens == 4'b0101) && ce[1]) ? 1'b1 : 1'b0;
				ce[3] = ((Mones == 4'b1001) && ce[2]) ? 1'b1 : 1'b0;
				
				reset[0] = (Sones == 4'b1001) ? 1'b1 : 1'b0;
		 		reset[1] = ((Stens == 4'b0101) && reset[0]) ? 1'b1 : 1'b0;
		 		reset[2] = ((Mones == 4'b1001) && reset[1]) ? 1'b1 : 1'b0;
		 		reset[3] = ((Mtens == 4'b0101) && reset[2]) ? 1'b1 : 1'b0;

				alarmmatching = ((Mtens == AMtens) && (Mones == AMones) && (Stens == AStens) && (Stens == ASones)) ? 1'b1 : 1'b0;
		 	end
			else begin
				ce[0] = 1'b0;
				ce[1] = 1'b0;
				ce[2] = 1'b0;
				ce[3] = 1'b0;
				
				reset[0] = 1'b0;
		 		reset[1] = 1'b0;
		 		reset[2] = 1'b0;
		 		reset[3] = 1'b0;
			end
		end

		 assign did_alarmMatch = alarmmatching;

	     countrce countrce1(.q(Sones[3:0]), .d(bu_rx_data[3:0]), .ld(dicLdSones), .ce(ce[0] || dicLdSones), .rst(reset[0]), .clk(clk));
		 countrce countrce2(.q(Stens[3:0]), .d(bu_rx_data[3:0]), .ld(dicLdStens), .ce(ce[1] || dicLdStens), .rst(reset[1]), .clk(clk));
		 countrce countrce3(.q(Mones[3:0]), .d(bu_rx_data[3:0]), .ld(dicLdMones), .ce(ce[2] || dicLdMones), .rst(reset[2]), .clk(clk));
		 countrce countrce4(.q(Mtens[3:0]), .d(bu_rx_data[3:0]), .ld(dicLdMtens), .ce(ce[3] || dicLdMtens), .rst(reset[3]), .clk(clk));

		 regrce regrce1(.q(ASones[3:0]), .d(bu_rx_data[3:0]), .ce(dicLdASones), .rst(rst), .clk(clk));
		 regrce regrce2(.q(AStens[3:0]), .d(bu_rx_data[3:0]), .ce(dicLdAStens), .rst(rst), .clk(clk));
		 regrce regrce3(.q(AMones[3:0]), .d(bu_rx_data[3:0]), .ce(dicLdAMones), .rst(rst), .clk(clk));
		 regrce regrce4(.q(AMtens[3:0]), .d(bu_rx_data[3:0]), .ce(dicLdAMtens), .rst(rst), .clk(clk));
		 

endmodule




//
//
// sample interface for clock control
//
module dictrl(
	      output reg  dicLdMtens, // load the 10's minutes
	      output reg  dicLdMones, // load the 1's minutes
	      output reg  dicLdStens, // load the 10's seconds
	      output reg  dicLdSones, // load the 1's seconds
	      output reg  dicLdAMtens, // load the alarm 10's minutes
	      output reg  dicLdAMones, // load the alarm 1's minutes
	      output reg  dicLdAStens, // load the alarm 10's seconds
	      output reg  dicLdASones, // load the alarm 1's seconds
	      output reg  dicRun, // clock should run
		  output wire loadalarm,
	      output wire dicAlarmIdle, // alarm is off
	      output wire dicAlarmArmed, // alarm is armed
	      output wire dicAlarmTrig, // alarm is triggered

		  input oneSecStrb,
	      input       did_alarmMatch, // raw alarm match

              input 	  bu_rx_data_rdy, // new data from uart rdy
              input [7:0] dataIn, // new data from uart
              input 	  rst,
	      input 	  clk
	      );

		  parameter [3:0] s0 = 4'b0000, s1 = 4'b0001, s2 = 4'b0010, s3 = 4'b0011, s4 = 4'b0100, 
		  s5 = 4'b0101, s6 = 4'b0110, s7 = 4'b0111, s8 = 4'b1000, s9 = 4'b1001, s10 = 4'b1010;
		  reg [3:0] next_state, state;

		  parameter [1:0] alarmOff = 2'b00, alarmArm = 2'b01, alarmTrig = 2'b10;
		  reg [1:0]	next_alarmstate, alarmstate;

		  parameter [7:0] zero =  8'b00110000,
		  				  five =  8'b00110101,
		  				  nine =  8'b00111001,
						  cr =    8'b00001101,
						  a =     8'b01100001,
		  				  l =     8'b01101100,
						  at =    8'b01000000;

		  reg alarm1, alarm2, alarm3;

		  assign loadalarm = ((state == s1) || (state == s2) || (state == s3) || (state == s4));
		  assign dicAlarmIdle = alarm1;
		  assign dicAlarmArmed = alarm2;
		  assign dicAlarmTrig = alarm3;

		always @(posedge clk) begin
			if(rst)
				state <= s0;
			else if (bu_rx_data_rdy)
				state <= next_state;
		end

		always @(posedge clk) begin
			if(rst)
				alarmstate <= alarmOff;
			else if (oneSecStrb)
				alarmstate <= next_alarmstate;
		end

		always @(*) begin
			dicRun = (state == s0);
			dicLdMtens = (state == s6);
			dicLdMones = (state == s7);
			dicLdStens = (state == s8);
			dicLdSones = (state == s9);
			dicLdAMtens = (state == s1);
			dicLdAMones = (state == s2);
			dicLdAStens = (state == s3);
			dicLdASones = (state == s4);

			alarm1 = (alarmstate == alarmOff);
			alarm2 = (alarmstate == alarmArm);
			alarm3 = (alarmstate == alarmTrig);
		end

		always @(did_alarmMatch, dataIn) begin
			case (alarmstate)
				alarmOff:begin
					if(dataIn == at)
						next_alarmstate <= alarmArm;
					else
						next_alarmstate <= alarmOff;
				end
				alarmArm:begin
					if(dataIn == at)
						next_alarmstate <= alarmOff;
					else if (did_alarmMatch)
						next_alarmstate <= alarmTrig;
					else
						next_alarmstate <= alarmArm;
				end
				alarmTrig:begin
					if(dataIn == at)
						next_alarmstate <= alarmOff;
					else
						next_alarmstate <= alarmTrig;
				end
			endcase
		end

		always @(state, dataIn) begin
			case (state)
				s0: begin
					if(dataIn == a)
						next_state <= s1;
					else if(dataIn == l)
						next_state <= s6;
					else
						next_state <= s0;
				end
				s1: begin
					if((zero <= dataIn) && (dataIn <= five))
						next_state <= s2;
					else 
						next_state <= s1;
				end
				s2: begin
					if((zero <= dataIn) && (dataIn <= nine))
						next_state <= s3;
					else
						next_state <= s2;
				end
				s3: begin
					if((zero <= dataIn) && (dataIn <= five))
						next_state <= s4;
					else
						next_state <= s3;
				end
				s4: begin
					if((zero <= dataIn) && (dataIn <= nine))
						next_state <= s5;
					else
						next_state <= s4;
				end
				s5: begin
					if(dataIn == cr)
						next_state <= s0;
					else
						next_state <= s5;
				end
				s6: begin
					if((zero <= dataIn) && (dataIn <= five))
						next_state <= s7;
					else
						next_state <= s6;
				end
				s7: begin
					if((zero <= dataIn) && (dataIn <= nine))
						next_state <= s8;
					else
						next_state <= s7;
				end
				s8: begin
					if((zero <= dataIn) && (dataIn <= five))
						next_state <= s9;
					else
						next_state <= s8;
				end
				s9: begin
					if((zero <= dataIn) && (dataIn <= nine))
						next_state <= s10;
					else
						next_state <= s9;
				end
				s10: begin
					if(dataIn == cr)
						next_state <= s0;
					else
						next_state <= s10;
				end
			endcase
	end 
endmodule

