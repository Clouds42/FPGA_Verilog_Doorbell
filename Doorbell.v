module Doorbell
(input CK
,input BTN_RING
,input BTN_MODE
,input BTN_SONG
,output reg BEEP
,output reg[15:0]LED
,output reg[7:0]SEG
,output reg[7:0]CAT
);

reg[24:0]cnt_beep=25'b0;
reg[24:0]cnt_led=25'b0;
reg[29:0]cnt_ring=30'b0;//按下门铃后的延时计数器
reg[24:0]cnt_tune=25'b0;
reg[5:0]cnt_play=6'b0;
reg[25:0]tune=26'd47774;
reg[7:0]delay_led=8'b0;
reg[24:0]cnt_seg=1'b0;
reg[2:0]mode=1'b1;
reg[2:0]song=1'b1;
reg lock=1'b0;

wire BP_MODE;
wire BP_SONG;

//////
//锁//
/////
always@(posedge CK)
if(BTN_RING)
	lock<=1'b1;
else if(lock)begin
	cnt_ring<=cnt_ring+1'b1;
	if(cnt_ring[29]==1)begin
		lock<=1'b0;
		cnt_ring<=1'b0;
	end
end

////////////
//蜂鸣器部分//
////////////
always@(posedge CK)
	if(cnt_tune==25'h1000000)begin
		cnt_tune<=1'b0;
		cnt_play<=cnt_play+1'b1;
	end
	else if(cnt_play==6'd30)
		cnt_play<=0;
	else
		cnt_tune<=cnt_tune+1'b1;

always@(posedge CK)begin
	cnt_beep<=cnt_beep+1'b1;
	if(cnt_beep==tune&&lock&&((mode==3'b001)||(mode==3'b011)))begin
		BEEP<=~BEEP;
		cnt_beep<=0;
		case(song)
		3'b001:case(cnt_play)//致爱丽丝
			6'd00:tune<=26'd18960;
			6'd01:tune<=26'd21282;
			6'd02:tune<=26'd18960;
			6'd03:tune<=26'd21282;
			6'd04:tune<=26'd18960;
			6'd05:tune<=26'd25308;
			6'd06:tune<=26'd21282;
			6'd07:tune<=26'd23889;
			6'd08:tune<=26'd28409;
			6'd11:tune<=26'd47774;
			6'd12:tune<=26'd37919;
			6'd13:tune<=26'd28409;
			6'd14:tune<=26'd25308;
			6'd17:tune<=26'd37919;
			6'd18:tune<=26'd31887;
			6'd19:tune<=26'd25308;
			6'd20:tune<=26'd23889;
			6'd23:tune<=26'h1;//静音
			default:;
			endcase
		3'b010:case(cnt_play)//生日快乐
			6'd00:tune<=26'd63775;
			6'd01:tune<=26'h1;
			6'd02:tune<=26'd63775;
			6'd04:tune<=26'd56818;
			6'd06:tune<=26'd63775;
			6'd08:tune<=26'd47774;
			6'd10:tune<=26'd50617;
			
			6'd12:tune<=26'd63775;
			6'd13:tune<=26'h1;
			6'd14:tune<=26'd63775;
			6'd16:tune<=26'd56818;
			6'd18:tune<=26'd63775;
			6'd20:tune<=26'd42567;
			6'd22:tune<=26'd47774;
			6'd24:tune<=26'h1;
			default:;
			endcase
		3'b011:case(cnt_play)//小星星
			6'd00:tune<=26'd47774;
			6'd01:tune<=26'h1;
			6'd02:tune<=26'd47774;
			6'd04:tune<=26'd31887;
			6'd05:tune<=26'h1;
			6'd06:tune<=26'd31887;
			6'd08:tune<=26'd28409;
			6'd09:tune<=26'h1;
			6'd10:tune<=26'd28409;
			6'd12:tune<=26'd31887;//
			
			6'd14:tune<=26'd35790;
			6'd15:tune<=26'h1;
			6'd16:tune<=26'd35790;
			6'd18:tune<=26'd37919;
			6'd19:tune<=26'h1;
			6'd20:tune<=26'd37919;
			6'd22:tune<=26'd42567;
			6'd23:tune<=26'h1;
			6'd24:tune<=26'd42567;
			6'd26:tune<=26'd47774;
			6'd28:tune<=26'h1;
			default:;
			endcase
		3'b100:case(cnt_play)//平凡之路
			6'd00:tune<=26'd63775;
			6'd02:tune<=26'd56818;
			6'd04:tune<=26'd50617;
			6'd06:tune<=26'd47774;
			6'd08:tune<=26'd50617;
			6'd09:tune<=26'd47774;
			6'd12:tune<=26'd63775;
			6'd13:tune<=26'd56818;
			6'd14:tune<=26'h1;
			6'd15:tune<=26'd56818;
			6'd18:tune<=26'h1;
			default:;
			endcase
		3'b101:case(cnt_play)//两只老虎
			6'd00:tune<=26'd47774;
			6'd02:tune<=26'd42567;
			6'd04:tune<=26'd37919;
			6'd06:tune<=26'd47744;
			6'd07:tune<=26'h1;
			6'd08:tune<=26'd47774;
			6'd10:tune<=26'd42567;
			6'd12:tune<=26'd37919;
			6'd14:tune<=26'd47774;

			6'd16:tune<=26'd37919;
			6'd18:tune<=26'd35790;
			6'd20:tune<=26'd31887;
			6'd22:tune<=26'h1;

			6'd24:tune<=26'd37919;
			6'd26:tune<=26'd35790;
			6'd28:tune<=26'd31887;
			6'd30:tune<=26'h1;//
			default:;
			endcase
		default:;
		endcase
	end
end
//6'd23:tune<=26'h2000000;//令蜂鸣器静音
/////////
//流水灯//
/////////
always@(posedge CK)
	if(cnt_led==25'd4999999)
		cnt_led<=25'd0;
	else
		cnt_led<=cnt_led+1'b1;

always@(posedge CK)begin
	if(cnt_led==25'd4999999&&lock&&((mode==3'b010)||(mode==3'b011)))begin
	delay_led<=delay_led+1;
	case(delay_led)
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
	8'd20:delay_led<=1'b0;
	endcase
	end
	else if(!lock||(mode==3'b001)||(mode==3'b100))
		LED<=16'b00000000_00000000;
end

/////////////
//数码管部分//
////////////
always@(posedge BP_MODE)begin
	if(mode==3'b100)
		mode<=3'b001;
	else
		mode<=mode+1'b1;
end

always@(posedge BP_SONG)begin
	if(song==3'b101)
		song<=3'b001;
	else
		song<=song+1'b1;
end

always@(posedge CK)
	if(cnt_seg==25'h7a11f)//数码管扫描周期
		cnt_seg<=1'b0;
	else
		cnt_seg<=cnt_seg+1'b1;

always@(posedge CK)begin
	if(cnt_seg==25'h3d08e)begin
	case(mode)
	3'b001:SEG<=8'h06;
	3'b010:SEG<=8'h5b;
	3'b011:SEG<=8'h4f;
	3'b100:SEG<=8'h66;
	default:;
	endcase
	CAT<=8'b11111110;
	end
	else if(cnt_seg==25'h7a11f)begin
	case(song)
	3'b001:SEG<=8'h06;
	3'b010:SEG<=8'h5b;
	3'b011:SEG<=8'h4f;
	3'b100:SEG<=8'h66;
	3'b101:SEG<=8'h6d;
	default:;
	endcase
	CAT<=8'b11111011;
	end
end

Debounce(.CK(CK),.KEY(BTN_MODE),.KP(BP_MODE));
Debounce(.CK(CK),.KEY(BTN_SONG),.KP(BP_SONG));

endmodule

///////
//消抖//
///////
module Debounce
(input CK
,input KEY
,output KP
);

reg[18:0]cnt_h;
reg[18:0]cnt_l;
reg kp;

always @(posedge CK)
	if(KEY==1'b0)
		cnt_l<=cnt_l+1;
	else
		cnt_l<=0;

always@(posedge CK)
	if(KEY==1'b1)
		cnt_h<=cnt_h+1;
	else
		cnt_h<= 0;

always@(posedge CK)
	if(cnt_h==19'h7a120)
		kp<=1;
	else if(cnt_l==19'h7a120)
		kp<=0;

assign KP=kp;

endmodule