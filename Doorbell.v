module Doorbell
(input CLK
,input BTN_DRBL//Doorbell
,input BTN_MODE
,input BTN_TRCK//Track
,output reg BEEP
,output reg[15:0]LED
,output reg[6:0]SEG
,output reg[7:0]CAT
,output LCD_E
,output reg LCD_RS
,output reg[7:0]LCD_DATA
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

//parameter[25:0]l1=26'd95565;
//parameter[25:0]l2=26'd85120;
//parameter[25:0]l3=26'd75849;
//parameter[25:0]l4=26'd71592;
parameter[25:0]l5=26'd63775;
parameter[25:0]l6=26'd56818;
parameter[25:0]l7=26'd50617;
parameter[25:0]m1=26'd47774;
parameter[25:0]m2=26'd42567;
parameter[25:0]m3=26'd37919;
parameter[25:0]m4=26'd35790;
parameter[25:0]m5=26'd31887;
parameter[25:0]m6=26'd28409;
parameter[25:0]m7=26'd25308;
parameter[25:0]h1=26'd23889;
parameter[25:0]h2=26'd21282;
parameter[25:0]h3=26'd18960;
//parameter[25:0]h4=26'd17896;
//parameter[25:0]h5=26'd15943;
//parameter[25:0]h6=26'd14204;
//parameter[25:0]h7=26'd12655;
parameter[25:0]mute=26'd1;

wire BP_MODE;
wire BP_TRCK;

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
			3'b010:case(cnt_beep_prgs)//Happy birthday
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
	else
		BEEP<=BEEP;
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
	if(cnt_led_div==25'd5000000&&lock&&((mode==3'b010)))begin
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
			default:;
		endcase
	end
	else if(lock&&mode==3'b011)
		case(pitch)
			l5:LED<=16'b00000000_00000001;
			l6:LED<=16'b00000000_00000010;
			l7:LED<=16'b00000000_00000100;
			m1:LED<=16'b00000000_00001000;
			m2:LED<=16'b00000000_00010000;
			m3:LED<=16'b00000000_00100000;
			m4:LED<=16'b00000000_01000000;
			m5:LED<=16'b00000000_10000000;
			m6:LED<=16'b00000001_00000000;
			m7:LED<=16'b00000010_00000000;
			h1:LED<=16'b00000100_00000000;
			h2:LED<=16'b00001000_00000000;
			h3:LED<=16'b00010000_00000000;
		default:;
		endcase
	else if(!lock)
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

always@(posedge BP_TRCK)
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
			3'b001:SEG<=7'h06;
			3'b010:SEG<=7'h5b;
			3'b011:SEG<=7'h4f;
			3'b100:SEG<=7'h66;
		default:;
		endcase
		CAT<=8'b1111_1110;
	end
	else if(cnt_seg==25'd500000)begin
		case(trck)
			3'b001:SEG<=7'h06;
			3'b010:SEG<=7'h5b;
			3'b011:SEG<=7'h4f;
			3'b100:SEG<=7'h66;
			3'b101:SEG<=7'h6d;
		default:;
		endcase
		CAT<=8'b1111_1011;
	end

///////
//LCD//
///////
reg[127:0]row1;
reg[127:0]row2;
always@(posedge CLK)
    case(trck)
        3'd1:begin row1<="     Song 1     ";row2<="    Fur Elise   ";end
        3'd2:begin row1<="     Song 2     ";row2<=" Happy Birthday ";end
        3'd3:begin row1<="     Song 3     ";row2<="  Little  Star  ";end
        3'd4:begin row1<="     Song 4     ";row2<="Fucking  Nothing";end
		3'd5:begin row1<="     Song 5     ";row2<="  Brother John  ";end
        default:;
    endcase

wire[127:0]row_1;
wire[127:0]row_2;
assign row_1=row1;//Content of the first row
assign row_2=row2;//Content of the second row

parameter TIME_20MS=1_000_000;//LCD needs 20ms to initialize
parameter TIME_500HZ=100_000;//Working frequency

parameter IDLE=8'h00;//The state machine has 40 states,so it takes gray codes
parameter SET_FUNCTION=8'h01;       
parameter DISP_OFF=8'h03;
parameter DISP_CLEAR=8'h02;
parameter ENTRY_MODE=8'h06;
parameter DISP_ON=8'h07;

parameter ROW1_ADDR=8'h05;       
parameter ROW1_0=8'h04;
parameter ROW1_1=8'h0C;
parameter ROW1_2=8'h0D;
parameter ROW1_3=8'h0F;
parameter ROW1_4=8'h0E;
parameter ROW1_5=8'h0A;
parameter ROW1_6=8'h0B;
parameter ROW1_7=8'h09;
parameter ROW1_8=8'h08;
parameter ROW1_9=8'h18;
parameter ROW1_A=8'h19;
parameter ROW1_B=8'h1B;
parameter ROW1_C=8'h1A;
parameter ROW1_D=8'h1E;
parameter ROW1_E=8'h1F;
parameter ROW1_F=8'h1D;

parameter ROW2_ADDR=8'h1C;
parameter ROW2_0=8'h14;
parameter ROW2_1=8'h15;
parameter ROW2_2=8'h17;
parameter ROW2_3=8'h16;
parameter ROW2_4=8'h12;
parameter ROW2_5=8'h13;
parameter ROW2_6=8'h11;
parameter ROW2_7=8'h10;
parameter ROW2_8=8'h30;
parameter ROW2_9=8'h31;
parameter ROW2_A=8'h33;
parameter ROW2_B=8'h32;
parameter ROW2_C=8'h36;
parameter ROW2_D=8'h37;
parameter ROW2_E=8'h35;
parameter ROW2_F=8'h34;

//20ms.Begin to initialize
reg[19:0]cnt_20ms;
always@(posedge CLK or negedge BTN_TRCK)
    if(!BTN_TRCK)
        cnt_20ms<=1'b0;
    else if(cnt_20ms==TIME_20MS-1'b1)
        cnt_20ms<=cnt_20ms;
    else
        cnt_20ms<=cnt_20ms+1'b1 ;

wire delay_done=(cnt_20ms==TIME_20MS-1)?1'b1:1'b0;

//LCD:500Hz.Frequency division
reg[19:0]cnt_500hz;
always@(posedge CLK or negedge BTN_TRCK)
    if(!BTN_TRCK)
        cnt_500hz<=1'b0;
    else if(delay_done)
        if(cnt_500hz==TIME_500HZ-1'b1)
            cnt_500hz<=1'b0;
        else
            cnt_500hz<=cnt_500hz+1'b1 ;
    else
        cnt_500hz<=1'b0;

assign LCD_E=(cnt_500hz>(TIME_500HZ-1'b1)/2)?1'b0:1'b1;//Negative edge

wire write_flag;
assign write_flag=(cnt_500hz==TIME_500HZ-1'b1)?1'b1:1'b0;

//set function,display off,display clear,entry mode set
reg[5:0]c_state;
reg[5:0]n_state;

always@(posedge CLK or negedge BTN_TRCK)
    if(!BTN_TRCK)
        c_state<=IDLE;
    else if(write_flag)
        c_state<=n_state;
    else
        c_state<=c_state;

always@(*)
    case (c_state)
        IDLE:n_state=SET_FUNCTION;
        SET_FUNCTION:n_state=DISP_OFF;
        DISP_OFF:n_state=DISP_CLEAR;
        DISP_CLEAR:n_state=ENTRY_MODE;
        ENTRY_MODE:n_state=DISP_ON;
        DISP_ON:n_state=ROW1_ADDR;
        ROW1_ADDR:n_state=ROW1_0;
        ROW1_0:n_state=ROW1_1;
        ROW1_1:n_state=ROW1_2;
        ROW1_2:n_state=ROW1_3;
        ROW1_3:n_state=ROW1_4;
        ROW1_4:n_state=ROW1_5;
        ROW1_5:n_state=ROW1_6;
        ROW1_6:n_state=ROW1_7;
        ROW1_7:n_state=ROW1_8;
        ROW1_8:n_state=ROW1_9;
        ROW1_9:n_state=ROW1_A;
        ROW1_A:n_state=ROW1_B;
        ROW1_B:n_state=ROW1_C;
        ROW1_C:n_state=ROW1_D;
        ROW1_D:n_state=ROW1_E;
        ROW1_E:n_state=ROW1_F;
        ROW1_F:n_state=ROW2_ADDR;

        ROW2_ADDR:n_state=ROW2_0;
        ROW2_0:n_state=ROW2_1;
        ROW2_1:n_state=ROW2_2;
        ROW2_2:n_state=ROW2_3;
        ROW2_3:n_state=ROW2_4;
        ROW2_4:n_state=ROW2_5;
        ROW2_5:n_state=ROW2_6;
        ROW2_6:n_state=ROW2_7;
        ROW2_7:n_state=ROW2_8;
        ROW2_8:n_state=ROW2_9;
        ROW2_9:n_state=ROW2_A;
        ROW2_A:n_state=ROW2_B;
        ROW2_B:n_state=ROW2_C;
        ROW2_C:n_state=ROW2_D;
        ROW2_D:n_state=ROW2_E;
        ROW2_E:n_state=ROW2_F;
        ROW2_F:n_state=ROW1_ADDR;
        default:;
    endcase   

always@(posedge CLK or negedge BTN_TRCK)
    if(!BTN_TRCK)
        LCD_RS<=1'b0;//Order or data.0:order,1:data
    else if(write_flag)
        if((n_state==SET_FUNCTION)||(n_state==DISP_OFF)||(n_state==DISP_CLEAR)||(n_state==ENTRY_MODE)||(n_state==DISP_ON)||(n_state==ROW1_ADDR)||(n_state==ROW2_ADDR))
            LCD_RS<=1'b0; 
        else
            LCD_RS<=1'b1;
    else
        LCD_RS<=LCD_RS;                        

always@(posedge CLK or negedge BTN_TRCK)
    if(!BTN_TRCK)
        LCD_DATA<=1'b0 ;
    else if(write_flag)
        case(n_state)
            IDLE:LCD_DATA<=8'hxx;
            SET_FUNCTION:LCD_DATA<=8'h38;//2*16,5*8,8-bit data
            DISP_OFF:LCD_DATA<=8'h08;
            DISP_CLEAR:LCD_DATA<=8'h01;
            ENTRY_MODE:LCD_DATA<=8'h06;
            DISP_ON:LCD_DATA<=8'h0c;//Display on,no cursor,no flicker

            ROW1_ADDR:LCD_DATA<=8'h80;//00+80
            ROW1_0:LCD_DATA<=row_1[127:120];
            ROW1_1:LCD_DATA<=row_1[119:112];
            ROW1_2:LCD_DATA<=row_1[111:104];
            ROW1_3:LCD_DATA<=row_1[103: 96];
            ROW1_4:LCD_DATA<=row_1[ 95: 88];
            ROW1_5:LCD_DATA<=row_1[ 87: 80];
            ROW1_6:LCD_DATA<=row_1[ 79: 72];
            ROW1_7:LCD_DATA<=row_1[ 71: 64];
            ROW1_8:LCD_DATA<=row_1[ 63: 56];
            ROW1_9:LCD_DATA<=row_1[ 55: 48];
            ROW1_A:LCD_DATA<=row_1[ 47: 40];
            ROW1_B:LCD_DATA<=row_1[ 39: 32];
            ROW1_C:LCD_DATA<=row_1[ 31: 24];
            ROW1_D:LCD_DATA<=row_1[ 23: 16];
            ROW1_E:LCD_DATA<=row_1[ 15:  8];
            ROW1_F:LCD_DATA<=row_1[  7:  0];

            ROW2_ADDR:LCD_DATA<=8'hc0;//40+80
            ROW2_0:LCD_DATA<=row_2[127:120];
            ROW2_1:LCD_DATA<=row_2[119:112];
            ROW2_2:LCD_DATA<=row_2[111:104];
            ROW2_3:LCD_DATA<=row_2[103: 96];
            ROW2_4:LCD_DATA<=row_2[ 95: 88];
            ROW2_5:LCD_DATA<=row_2[ 87: 80];
            ROW2_6:LCD_DATA<=row_2[ 79: 72];
            ROW2_7:LCD_DATA<=row_2[ 71: 64];
            ROW2_8:LCD_DATA<=row_2[ 63: 56];
            ROW2_9:LCD_DATA<=row_2[ 55: 48];
            ROW2_A:LCD_DATA<=row_2[ 47: 40];
            ROW2_B:LCD_DATA<=row_2[ 39: 32];
            ROW2_C:LCD_DATA<=row_2[ 31: 24];
            ROW2_D:LCD_DATA<=row_2[ 23: 16];
            ROW2_E:LCD_DATA<=row_2[ 15:  8];
            ROW2_F:LCD_DATA<=row_2[  7:  0];
        endcase                     
    else
        LCD_DATA<=LCD_DATA;

Debounce UUD1(CLK,BTN_MODE,BP_MODE);
Debounce UUD2(CLK,BTN_TRCK,BP_TRCK);

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