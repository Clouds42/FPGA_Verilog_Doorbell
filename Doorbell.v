module Doorbell
(input CLK
,input BTN_DRBL//Doorbell
,input BTN_MODE
,input BTN_TRCK//Track
,output reg BEEP
,output reg[15:0]LED
,output reg[7:0]SEG
,output reg[7:0]CAT
);

////////
//LOCK//
////////
reg[29:0]cnt_drbl=30'b0;//The duration of ring
reg lock=1'b0;

always@(posedge CLK)
	if(BTN_DRBL)
		lock<=1'b1;
	else if(lock)begin
		cnt_drbl<=cnt_drbl+1'b1;
		if(cnt_drbl[29]==1)begin//268,435,456*20=5,368,709,120ns=5.3s
			lock<=1'b0;
			cnt_drbl<=1'b0;
		end
	end

////////
//BEEP//
////////
reg[24:0]cnt_beep=25'b0;//Generate square waves in different frequency
reg[24:0]cnt_beep_div=25'b0;//Control the duration of every single note
reg[5:0]cnt_beep_prgs=6'b0;//The progress of music
reg[25:0]pitch=26'd47774;//Control the pitch of every single note
reg[2:0]mode=1'b1;
reg[2:0]trck=1'b1;

parameter
l1=95565,l2=85120,l3=75849,l4=71592,
l5=63775,l6=56818,l7=50617,
m1=47774,m2=42567,m3=37919,m4=35790,
m5=31887,m6=28409,m7=25308,
h1=23889,h2=21282,h3=18960,h4=17896,
h5=15943,h6=14204,h7=12655,
mute=1;//Define the note

wire BP_MODE;
wire BP_SONG;

always@(posedge CLK)
	if(cnt_beep_div==25'h1000000)begin//16,777,216/50,000,000=335.5ms
		cnt_beep_div<=1'b0;
		cnt_beep_prgs<=cnt_beep_prgs+1'b1;
	end
	else if(cnt_beep_prgs==6'd30)//The length of music
		cnt_beep_prgs<=0;
	else
		cnt_beep_div<=cnt_beep_div+1'b1;

always@(posedge CLK)begin
	cnt_beep<=cnt_beep+1'b1;
	if(cnt_beep==pitch&&lock&&((mode==3'b001)||(mode==3'b011)))begin
		BEEP<=~BEEP;
		cnt_beep<=0;
		case(trck)//Choose tracks
			3'b001:case(cnt_beep_prgs)//Fur Elise
				6'd00:pitch<=h3;
				6'd01:pitch<=h2;
				6'd02:pitch<=h3;
				6'd03:pitch<=h2;
				6'd04:pitch<=h3;
				6'd05:pitch<=m7;
				6'd06:pitch<=h2;
				6'd07:pitch<=h1;
				6'd08:pitch<=m6;

				6'd11:pitch<=m1;
				6'd12:pitch<=m3;
				6'd13:pitch<=m6;
				6'd14:pitch<=m7;
				6'd17:pitch<=m3;
				6'd18:pitch<=m5;
				6'd19:pitch<=m7;
				6'd20:pitch<=h1;
				6'd23:pitch<=mute;//Mute
				default:;
				endcase
			3'b010:case(cnt_beep_prgs)//Happy birthday to you
				6'd00:pitch<=l5;
				6'd01:pitch<=mute;
				6'd02:pitch<=l5;
				6'd04:pitch<=l6;
				6'd06:pitch<=l5;
				6'd08:pitch<=m1;
				6'd10:pitch<=l7;
				
				6'd12:pitch<=l5;
				6'd13:pitch<=mute;
				6'd14:pitch<=l5;
				6'd16:pitch<=l6;
				6'd18:pitch<=l5;
				6'd20:pitch<=m2;
				6'd22:pitch<=m1;
				6'd24:pitch<=mute;
				default:;
				endcase
			3'b011:case(cnt_beep_prgs)//Little star
				6'd00:pitch<=m1;
				6'd01:pitch<=mute;
				6'd02:pitch<=m1;
				6'd04:pitch<=m5;
				6'd05:pitch<=mute;
				6'd06:pitch<=m5;
				6'd08:pitch<=m6;
				6'd09:pitch<=mute;
				6'd10:pitch<=m6;
				6'd12:pitch<=m5;
				
				6'd14:pitch<=m4;
				6'd15:pitch<=mute;
				6'd16:pitch<=m4;
				6'd18:pitch<=m3;
				6'd19:pitch<=mute;
				6'd20:pitch<=m3;
				6'd22:pitch<=m2;
				6'd23:pitch<=mute;
				6'd24:pitch<=m2;
				6'd26:pitch<=m1;
				6'd28:pitch<=mute;
				default:;
				endcase
			3'b100:case(cnt_beep_prgs)//Empty
				6'd00:pitch<=mute;
				default:;
				endcase
			3'b101:case(cnt_beep_prgs)//Brother John
				6'd00:pitch<=m1;
				6'd02:pitch<=m2;
				6'd04:pitch<=m3;
				6'd06:pitch<=m1;
				6'd07:pitch<=mute;
				6'd08:pitch<=m1;
				6'd10:pitch<=m2;
				6'd12:pitch<=m3;
				6'd14:pitch<=m1;

				6'd16:pitch<=m3;
				6'd18:pitch<=m4;
				6'd20:pitch<=m5;
				6'd22:pitch<=mute;

				6'd24:pitch<=m3;
				6'd26:pitch<=m4;
				6'd28:pitch<=m5;
				6'd30:pitch<=mute;
				default:;
				endcase
			default:;
		endcase
	end
end

///////
//LED//
///////
reg[24:0]cnt_led_div=25'b0;//Control the period of state transition
reg[7:0]cnt_led_prgs=8'b0;//The progress of led shining

always@(posedge CLK)
	if(cnt_led_div==25'd5000000)//5,000,000/50,000,000=100ms,10Hz
		cnt_led_div<=25'd0;
	else
		cnt_led_div<=cnt_led_div+1'b1;

always@(posedge CLK)
	if(cnt_led_div==25'd5000000&&lock&&((mode==3'b010)||(mode==3'b011)))begin
		cnt_led_prgs<=cnt_led_prgs+1'b1;
		case(cnt_led_prgs)
			8'd00:LED<=16'b10000000_00000000;
			8'd01:LED<=16'b11000000_00000000;
			8'd02:LED<=16'b11100000_00000000;
			8'd03:LED<=16'b01110000_00000000;
			8'd04:LED<=16'b00111000_00000000;
			8'd05:LED<=16'b00011100_00000000;
			8'd06:LED<=16'b00001110_00000000;
			8'd07:LED<=16'b00000111_00000000;
			8'd08:LED<=16'b00000011_10000000;
			8'd09:LED<=16'b00000001_11000000;
			8'd10:LED<=16'b00000000_11100000;
			8'd11:LED<=16'b00000000_01110000;
			8'd12:LED<=16'b00000000_00111000;
			8'd13:LED<=16'b00000000_00011100;
			8'd14:LED<=16'b00000000_00001110;
			8'd15:LED<=16'b00000000_00000111;
			8'd16:LED<=16'b00000000_00000011;
			8'd17:LED<=16'b00000000_00000001;
			8'd18:LED<=16'b00000000_00000000;
			8'd20:cnt_led_prgs<=1'b0;
		endcase
	end
	else if(!lock||(mode==3'b001)||(mode==3'b100))
		LED<=16'b00000000_00000000;

////////
//DISP//
////////
reg[24:0]cnt_seg=1'b0;//The scan frequency of segment displays

always@(posedge BP_MODE)
	if(mode==3'b100)
		mode<=3'b001;
	else
		mode<=mode+1'b1;

always@(posedge BP_SONG)
	if(trck==3'b101)
		trck<=3'b001;
	else
		trck<=trck+1'b1;

always@(posedge CLK)
	if(cnt_seg==25'd500000)//500,000/50,000,000=10ms,100Hz
		cnt_seg<=1'b0;
	else
		cnt_seg<=cnt_seg+1'b1;

always@(posedge CLK)
	if(cnt_seg==25'd250000)begin
		case(mode)
			3'b001:SEG<=8'h06;
			3'b010:SEG<=8'h5b;
			3'b011:SEG<=8'h4f;
			3'b100:SEG<=8'h66;
		default:;
		endcase
		CAT<=8'b11111110;
	end
	else if(cnt_seg==25'd500000)begin
		case(trck)
			3'b001:SEG<=8'h06;
			3'b010:SEG<=8'h5b;
			3'b011:SEG<=8'h4f;
			3'b100:SEG<=8'h66;
			3'b101:SEG<=8'h6d;
		default:;
		endcase
		CAT<=8'b11111011;
	end

Debounce i1(CLK,BTN_MODE,BP_MODE);
Debounce i2(CLK,BTN_TRCK,BP_SONG);

endmodule

////////////
//Debounce//
////////////
module Debounce
(input CLK
,input KEY
,output KP
);

reg[18:0]cnt_h=19'b0;
reg[18:0]cnt_l=19'b0;
reg kp;

always @(posedge CLK)
	if(KEY==1'b0)
		cnt_l<=cnt_l+1'b1;
	else
		cnt_l<=19'b0;

always@(posedge CLK)
	if(KEY==1'b1)
		cnt_h<=cnt_h+1'b1;
	else
		cnt_h<=19'b0;

always@(posedge CLK)
	if(cnt_h==19'd500000)//10ms
		kp<=1;
	else if(cnt_l==19'd500000)
		kp<=0;

assign KP=kp;

endmodule