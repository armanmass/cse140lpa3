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
		  output wire 	    L3_tx_data_rdy, // data to the uart is ready
		  output wire [7:0] L3_tx_data,
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



   wire 			    dicAlarmIdle;
   wire 			    dicAlarmArmed;
   wire 			    dicAlarmTrig;
   
   wire [7:0] 			    diAlStatus;  // alarm status character
   assign diAlStatus = 
		       dicAlarmTrig ? "T" :
		       dicAlarmArmed ? "a" :
		       ".";
   
   dispString dspStr (
			 .rdy(L3_tx_data_rdy), .dOut(L3_tx_data),
			 .b0({4'h3, di_AMtens}), .b1({4'h3, di_AMones}),
			 .b2(":"),		 .b3({4'h3, di_AStens}),
			 .b4({4'h3, di_ASones}), .b5(" "),
			 .b6(diAlStatus),
			 .go(oneSecStrb),	 .rst(rst),
			 .clk(clk)
			 );
   

   wire 		       dicDspSones;
   wire 		       dicDspStens;
   wire 		       dicDspMones;
   wire 		       dicDspMtens;
   wire [6:0] 		       L3_segment1P;
   wire [6:0] 		       L3_segment2P;
   wire [6:0] 		       L3_segment3P;
   wire [6:0] 		       L3_segment4P;
   
   always @(posedge clk) begin
      L3_segment1 <= L3_segment1P;
      L3_segment2 <= L3_segment2P;
      L3_segment3 <= L3_segment3P;
      L3_segment4 <= L3_segment4P;
   end

   bcd2segment dec0 (L3_segment1P, di_Sones, dicDspSones);
   bcd2segment dec1 (L3_segment2P, di_Stens, dicDspStens);
   bcd2segment dec2 (L3_segment3P, di_Mones, dicDspMones);
   bcd2segment dec3 (L3_segment4P, di_Mtens, dicDspMtens);

   
   wire [3:0]		   di_iMtens;   // 10's minutes
   wire [3:0]		   di_iMones;   // 1's minutes
   wire [3:0]		   di_iStens;   // 10's seconds
   wire [3:0]		   di_iSones;   // 1's minutes
   wire                    dicAlSel;    // select alarm to main display
 		   
   assign di_Mtens = dicAlSel ? di_AMtens : di_iMtens;
   assign di_Mones = dicAlSel ? di_AMones : di_iMones;
   assign di_Stens = dicAlSel ? di_AStens : di_iStens;
   assign di_Sones = dicAlSel ? di_ASones : di_iSones;
   

   wire 	    dicLdMtens;  // load the 10's minutes
   wire 	    dicLdMones;  // load the 1's minutes
   wire 	    dicLdStens;  // load the 10's seconds
   wire 	    dicLdSones;  // load the 1's seconds
   wire 	    dicLdAMtens;  // load the alarm 10's minutes
   wire 	    dicLdAMones;  // load the alarm 1's minutes
   wire 	    dicLdAStens;  // load the alarm 10's seconds
   wire 	    dicLdASones;  // load the alarm 1's seconds
   wire 	    did_alarmMatch;  // alarm matches clock (unqualified)
   wire             dicRun;      // clock should run
   wire             de_littleN;  // lower cse n detected
   


   dictrl dictrl (
		  .dicLdMtens(dicLdMtens),
		  .dicLdMones(dicLdMones),
		  .dicLdStens(dicLdStens),
		  .dicLdSones(dicLdSones),
		  .dicLdAMtens(dicLdAMtens),
		  .dicLdAMones(dicLdAMones),
		  .dicLdAStens(dicLdAStens),
		  .dicLdASones(dicLdASones),
		  .dicRun(dicRun),
		  .dicDspMtens(dicDspMtens),
		  .dicDspMones(dicDspMones),
		  .dicDspStens(dicDspStens),
		  .dicDspSones(dicDspSones),
		  .dicAlSel(dicAlSel),
		  .de_littleN(de_littleN),
		  .dicAlarmIdle(dicAlarmIdle),
		  .dicAlarmArmed(dicAlarmArmed),
		  .dicAlarmTrig(dicAlarmTrig),
		  .did_alarmMatch(did_alarmMatch),
		  .bu_rx_data_rdy(bu_rx_data_rdy),
		  .bu_rx_data(bu_rx_data),
		  .rst(rst),
		  .clk(clk)
		  );

   didp   didp (
		.di_iMtens(di_iMtens), .di_iMones(di_iMones),
		.di_iStens(di_iStens), .di_iSones(di_iSones),
		.di_AMtens(di_AMtens), .di_AMones(di_AMones),
		.di_AStens(di_AStens), .di_ASones(di_ASones),

		.did_alarmMatch(did_alarmMatch),
		.L3_led(L3_led),
		.bu_rx_data(bu_rx_data),
		.dicLdMtens(dicLdMtens),
		.dicLdMones(dicLdMones),
		.dicLdStens(dicLdStens),
		.dicLdSones(dicLdSones),
		.dicLdAMtens(dicLdAMtens),
		.dicLdAMones(dicLdAMones),
		.dicLdAStens(dicLdAStens),
		.dicLdASones(dicLdASones),

		.dicRun(dicRun),
		.oneSecStrb (oneSecStrb),
		.de_littleN(de_littleN),
		.rst(rst),
		.clk(clk)
		);


endmodule // Lab3_140L



