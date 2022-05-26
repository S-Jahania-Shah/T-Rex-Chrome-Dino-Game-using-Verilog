`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2021 10:14:38 PM
// Design Name: 
// Module Name: Design
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module clk_div(clk,clk_d);
  input wire clk;
  output wire clk_d;
  reg [15:0]  counter;
  reg pixcel_step;
  
  always @(posedge clk)
    {pixcel_step, counter} <= counter + 16'h4000;
    
  assign clk_d = pixcel_step; 
endmodule
//--------------------------------------------------------------------------------------------------//
module h_counter(clock,hcount,trig_V);
  input clock;
  output [9:0] hcount;
  reg [9:0] hcount;
  output trig_V;
  reg trig_V;
  initial hcount=0;
  initial trig_V=0;
          always @ (posedge clock)
            begin 
              if (hcount <799)
              	begin
                  hcount <= hcount + 1;                
                end  
                  
              else
              	begin
                  hcount <=0;
                end
            end   
         always @ (posedge clock)
            begin 
              if (hcount ==799)
              	begin
                  trig_V <= trig_V +1;     
                end  
                  
              else
              	begin
                  trig_V <=0;
                end
            end   
               
endmodule

// -------------------------------------------------------------------------------------------//
module V_counter(clock,V_signal,Vcount);
  input clock,V_signal;
  output [9:0] Vcount;
  reg [9:0] Vcount;
  initial Vcount=0;
  
          always @ (posedge clock)
            begin 
              if (Vcount <524)
                begin
                  if (V_signal ==1)
                    begin
                      Vcount <= Vcount + 1;                
                    end
                  else
                    begin
                      Vcount<= Vcount;
                    end
                end  
              else
              	begin
                  Vcount <=0;
                end
            end   
                    
endmodule

// ----------------------------------------------------------------------------------------//

module VGA_sync (h_count,v_count,h_sync,v_sync,video_on,x_log,y_log);
  input [9:0] h_count,v_count;
  output video_on;
  output h_sync,v_sync;
  output [9:0] x_log;
  output [9:0] y_log;
  
  //horizontal
  localparam HD = 640;
  localparam HF = 16;
  localparam HB = 48;
  localparam HR = 96;
  
  //vertical
  localparam VD = 480;
  localparam VF = 10;
  localparam VB = 33;
  localparam VR = 2;
  
  assign h_sync = (h_count < (HD + HF)) || (h_count>= (HD+HF+HR));
  assign v_sync = (v_count < (VD + VF)) || (v_count>= (VD+VF+VR));
  assign video_on = (h_count < HD) && (v_count < VD);
  assign x_log = h_count;
  assign y_log = v_count;

endmodule

//-------------------------------------------------------------------------------------------//
       



module FSM(clk_div1,fsm_reset,fsm_input_user,state,mover_dino,mover);
//input fsm_input_coll;
input fsm_input_user;
input clk_div1;
input fsm_reset;
//////////
output reg[2:0]state = 3'b000;
output reg [9:0]mover = 639;
output reg[9:0]mover_dino = 380;
//output reg score_reset;
////////////////////////////////////////
reg flag = 1;
//output reg [15:0]score_counter;

reg fsm_coll;
reg[2:0] next;
 reg [17:0]counter_fsm = 0;
////////////////////////////
  parameter Idle = 3'b000;
  parameter Run = 3'b001;
  parameter MoveUp = 3'b010;
  parameter MoveDown = 3'b011;
  parameter Dead = 3'b100;
  
  assign ReachMax = (mover_dino<=150)? 1'b1:1'b0;
  assign ReachMin = (mover_dino>=380)? 1'b1:1'b0;
  
  

always @(posedge clk_div1 or posedge  fsm_reset or posedge fsm_input_user)//or posedge video_on)
begin
if (counter_fsm < 195619) 
            counter_fsm <= counter_fsm + 1;
       else
       begin
                counter_fsm=0;    
//                if (score_counter < 8000 )
//                    score_counter= score_counter +0;
//                else
//                    score_counter=0;
    
   if(fsm_reset==1)
   begin
      state=Idle;
      //score_reset=1;
    end
  	else
  	begin
  	
        
  	    if(((mover_dino+50)<438 && (mover_dino+50)>348)&& (mover<100 && (mover+25)>48))   
            fsm_coll <= 1;   
        else
            fsm_coll <= 0;
        state = next; 
      case(state)
        Idle:
        begin
        mover_dino<=380;
        mover <= 600;
        //score_reset<=1;
        
          if(fsm_input_user==1'b1)
          begin
            next <= Run;
            flag<=1;
            end
          else if(fsm_input_user == 1'b0)
            next <= Idle;
            end
        ///////////////////////////////////////////////////////////////////////////////////    
    	Run:
    	begin
    	mover_dino <= 380;
    	//score_reset<=0;
    	//////////
       
//        if (counter_fsm%40000==0)
//            score_counter=score_counter+1;
//        else
//            score_counter=score_counter+0;
       
         //////////
    	if(mover<=0)
                    mover <= 639;
                 else
                   mover <= mover - 2;
          if(fsm_coll== 1'b1)
          		next <= Dead;         
          else if (fsm_input_user== 1'b0)
                 begin
                 flag<=0;
                next <= Run;
                end
          else if(fsm_input_user == 1'b1)
            	next <= MoveUp;
        end
        /////////////////////////////////////////////////////////////////////////////////////////////////////
        MoveUp:
          begin
          mover_dino <= mover_dino-3;
          //score_reset<=0;
          //////////
     
//        if (counter_fsm%40000!=0)
//            score_counter=score_counter+1;
//        else
//            score_counter=score_counter+0;
        
      
         //////////
          if(mover<=0)
                    mover <= 639;
                 else
                   mover <= mover - 2;                       
          
          if(fsm_coll== 1'b1)
                next <= Dead;
          else if(ReachMax==1'b0)
                next <= MoveUp;
          else if(ReachMax==1'b1)
                next <= MoveDown;
          end      
        ///////////////////////////////////////////////////////////////////////        
        MoveDown:
        begin
        mover_dino <= mover_dino+3;
        //score_reset<=0;
        //////////
        
//        if (counter_fsm%40000!=0)
//            score_counter=score_counter+1;
//        else
//            score_counter=score_counter+0;
        
        
         //////////
        if(mover<=0)
                    mover <= 639;
                 else
                   mover <= mover - 2;
          if(fsm_coll== 1'b1)
                next <= Dead;
          else if(ReachMin== 1'b0)
                next <= MoveDown;
          else if(ReachMin==1'b1)
                next <= Run;
          end   
          /////////////////////////////////////////////////   
        Dead:
        begin
        //score_reset<=0;
          if(fsm_input_user == 1'b0)
                    next<=Dead;
          else if(fsm_input_user==1'b1)
                    next <= Idle;
          fsm_coll<=0;          
        end
        default:
          next = Idle;
        endcase
          end
        end
      end
       
    endmodule 
    
 ////////////////////////////////////////////////////////////
 module D_latch(D,clk,Q,Qnot,reset);
 input D;
 input clk;
 input reset;
 output reg Q;
 output reg Qnot;
 
 always @(posedge clk)  
    begin
    if(reset==1)
    begin
    Q <= 0;
    Qnot <= 1; 
    end
    else
    begin
    Q<=D;
    Qnot<=~D;
    end
    end
endmodule   

module Top_FSM(enter,gameover,reset,Ap,Bp,clk);
//input A; ///state1
//input B; ////state2
input enter;////enter
input reset;///reset
input gameover;///gameover
input clk;
output Ap,Bp;
wire clk_d;
wire A,B,dA,dB;


    assign dA = (~A&&B&&~reset&&gameover) || (A&&~B&&~reset&&gameover);
    assign dB = (~B&&enter)||(A&&~enter&&~reset) || (~A&&B&&~reset&&gameover);
    D_latch d1(.D(dA),.clk(clk_d),.Q(A),.Qnot(~A),.reset(reset));
    D_latch d2(.D(dB),.clk(clk_d),.Q(B),.Qnot(~B),.reset(reset));



endmodule  
    
//////////////////////////////////////////////
module game_won_display(pixel_x, pixel_y, display);
  input [9:0] pixel_x;
  input [9:0] pixel_y;
  output display;
  
  reg [0:29] startup [29:0];
  
  wire [5:0] x = pixel_x[9:4] - 5;
  wire [5:0] y = pixel_y[9:4];
  assign display = startup[y][x];
  
  initial begin
    startup[0]  = 30'b111111111111111111111111111111; 
    startup[1]  = 30'b100000000000000000000000000001; 
    startup[2]  = 30'b100000000000000000000000000001; 
    startup[3]  = 30'b100000000000000000000000000001; 
    startup[4]  = 30'b100000000000000000000000000001; 
    startup[5]  = 30'b100000000000000000000000000001; 
    startup[6]  = 30'b100000000000000000000000000001; 
    startup[7]  = 30'b100000000000000000000000000001; 
    startup[8]  = 30'b100000001010111010100000000001; 
    startup[9]  = 30'b100000001010101010100000000001; 
    startup[10] = 30'b100000001110101010100000000001; 
    startup[11] = 30'b100000000100101010100000000001; 
    startup[12] = 30'b100000000100101010100000000001; 
    startup[13] = 30'b100000000100111011100000000001; 
    startup[14] = 30'b100000000000000000000000000001;
    startup[15] = 30'b100000000000000000000000000001;
    startup[16] = 30'b100000010011101110111000000001; 
    startup[17] = 30'b100000010010101000010000000001; 
    startup[18] = 30'b100000010010101110010000000001; 
    startup[19] = 30'b100000010010100010010000000001; 
    startup[20] = 30'b100000011011101110010000000001; 
    startup[21] = 30'b100000000000000000000000000001; 
    startup[22] = 30'b100000000000000000000000000001; 
    startup[23] = 30'b100000000000000000000000000001; 
    startup[24] = 30'b100000000000000000000000000001; 
    startup[25] = 30'b100000000000000000000000000001; 
    startup[26] = 30'b100000000000000000000000000001; 
    startup[27] = 30'b100000000000000000000000000001; 
    startup[28] = 30'b100000000000000000000000000001; 
    startup[29] = 30'b111111111111111111111111111111; 
  end
endmodule
////////////////////////////////////////
module game_won_display_start(pixel_x, pixel_y, display);
  input [9:0] pixel_x;
  input [9:0] pixel_y;
  output display;
  
  reg [0:29] startup [29:0];
  
  wire [5:0] x = pixel_x[9:4] - 5;
  wire [5:0] y = pixel_y[9:4];
  assign display = startup[y][x];
  
  initial begin
    startup[0]  = 30'b111111111111111111111111111111; 
    startup[1]  = 30'b100000000000000000000000000001; 
    startup[2]  = 30'b100000000000000000000000000001; 
    startup[3]  = 30'b100000000000000000000000000001; 
    startup[4]  = 30'b100000000000000000000000000001; 
    startup[5]  = 30'b100000000000000000000000000001; 
    startup[6]  = 30'b100000000000000000000000000001; 
    startup[7]  = 30'b100000000000000000000000000001; 
    startup[8]  = 30'b100000000101011101010000000001; 
    startup[9]  = 30'b100000000101010101010000000001; 
    startup[10] = 30'b100000000111010101010000000001; 
    startup[11] = 30'b100000000010010101010000000001; 
    startup[12] = 30'b100000000010010101010000000001; 
    startup[13] = 30'b100000000010011101110000000001; 
    startup[14] = 30'b100000000000000000000000000001;
    startup[15] = 30'b100000000000000000000000000001;
    startup[16] = 30'b100000111011101110111001110001; 
    startup[17] = 30'b100000100001001010100100100001; 
    startup[18] = 30'b100000111001001110111000100001; 
    startup[19] = 30'b100000001001001010100100100001; 
    startup[20] = 30'b100000111001001010100100100001; 
    startup[21] = 30'b100000000000000000000000000001; 
    startup[22] = 30'b100000000000000000000000000001; 
    startup[23] = 30'b100000000000000000000000000001; 
    startup[24] = 30'b100000000000000000000000000001; 
    startup[25] = 30'b100000000000000000000000000001; 
    startup[26] = 30'b100000000000000000000000000001; 
    startup[27] = 30'b100000000000000000000000000001; 
    startup[28] = 30'b100000000000000000000000000001; 
    startup[29] = 30'b111111111111111111111111111111; 
  end
endmodule

module pixel_gen2(pixel_x,pixel_y,clk_div1,video_on,red,blue,green,state,mover_dino,mover);
  input [9:0] pixel_x,pixel_y;
  input clk_div1;
  input video_on;
  input [2:0]state;
  /////////////////////////////////
  input [9:0]mover_dino;
  input [9:0]mover;
  //output reg fsm_output_coll;
  output reg [3:0] red = 0;
  output reg [3:0] blue = 0;
  output reg [3:0] green = 0;
  wire display;
  game_won_display g1(pixel_x, pixel_y, display);
  wire display1;
  game_won_display_start p1(pixel_x, pixel_y, display1);
  ////////////////////////////////
  localparam px = 1;
  localparam defaultWidth = 88 * px;
  localparam defaultHeight = 94 * px;
  //reg [9:0]mover=639;
  
  
  
  always @(posedge clk_div1)//or posedge video_on) 
  begin
   
  
    if ((pixel_x <=0) || (pixel_x >=639)) 
      begin
        red <= 4'h0;
        blue <= 4'h0;
        green <= 4'h0;
      end
    else 
      begin
       
       
        if (state==3'b000)
        begin  
         if (display1) 
         begin
         red<=4'hF;
         blue<=4'hF;
         green<=4'h0;
         end
         
        
         else
         begin
         red<=4'h0;
         blue<=4'h0;
         green<=4'h0;
         end           
        end
        ///////////////////////////////////////////////////////////////////////////////
        else if(state==3'b001)
        begin  
        red   <= video_on ? ((pixel_x>=0) && (pixel_x <= 639) && ( pixel_y>=375) && (pixel_y <= 380)? 4'hF:4'h0 ) : 4'h0;
        blue   <= video_on ? (
((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 89 * px)) 

 

 

	|| ((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 88 * px)) 

 

	|| ((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 87 * px)) 

 

	|| ((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 86 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 85 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 84 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 83 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 83 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 82 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 82 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 81 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 81 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 80 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 80 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 79 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 78 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 77 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 76 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 75 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 74 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 73 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 72 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 71 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 70 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 69 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 68 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 67 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 66 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 65 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 64 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 63 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 62 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 61 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 60 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 59 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 59 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 58 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 58 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 57 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 57 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 56 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 56 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 55 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 55 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 54 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 54 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 53 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 53 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 52 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 52 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 51 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 51 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 50 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 50 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 49 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 49 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 48 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 48 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 47 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 47 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 47 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 46 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 46 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 46 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 45 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 45 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 45 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 44 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 44 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 44 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 43 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 42 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 41 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 40 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 39 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 38 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 37 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 36 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 35 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 34 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 33 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 32 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 31 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 30 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 29 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 28 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 27 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 26 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 25 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 24 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 23 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 22 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 21 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 20 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 19 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 19 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 18 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 18 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 17 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 17 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 16 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 16 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 15 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 15 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 14 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 14 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 13 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 13 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 12 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 12 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 11 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 11 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 10 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 10 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 9 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 9 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 8 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 8 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 7 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 7 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 6 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 6 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 5 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 5 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 4 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 4 * px)) 



? 4'hF:4'h0 ) : 4'h0;
        green   <= video_on ? (((pixel_x > mover + 14 * px) && (pixel_x <= mover + 19 * px) && (pixel_y == 375 - 67 * px))
	|| ((pixel_x > mover + 14 * px) && (pixel_x <= mover + 19 * px) && (pixel_y == 375 - 66 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 65 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 64 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 63 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 62 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 61 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 60 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 59 * px))
	|| ((pixel_x > mover + 28 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 59 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 58 * px))
	|| ((pixel_x > mover + 28 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 58 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 57 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 57 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 56 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 56 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 55 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 55 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 54 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 54 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 53 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 53 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 52 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 52 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 5 * px) && (pixel_y == 375 - 51 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 51 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 51 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 5 * px) && (pixel_y == 375 - 50 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 50 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 50 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 49 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 49 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 49 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 48 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 48 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 48 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 47 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 47 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 47 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 46 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 46 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 46 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 45 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 45 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 45 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 44 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 44 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 44 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 43 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 43 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 43 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 42 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 42 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 42 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 41 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 41 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 41 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 40 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 40 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 40 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 39 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 39 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 39 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 38 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 38 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 38 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 37 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 37 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 36 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 36 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 35 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 35 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 34 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 34 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 33 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 27 * px) && (pixel_y == 375 - 33 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 32 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 27 * px) && (pixel_y == 375 - 32 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 31 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 31 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 30 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 30 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 29 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 28 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 27 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 26 * px))
	|| ((pixel_x > mover + 6 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 25 * px))
	|| ((pixel_x > mover + 6 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 24 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 23 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 22 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 21 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 20 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 19 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 18 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 17 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 16 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 15 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 14 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 13 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 12 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 11 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 10 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 9 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 8 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 7 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 6 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 5 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 4 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 3 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 2 * px))? 4'hF:4'h0 ) : 4'h0;
        end
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        else if(state==3'b010)
        begin  
        red   <= video_on ? ((pixel_x>=0) && (pixel_x <= 639) && ( pixel_y>=375) && (pixel_y <= 380)? 4'hF:4'h0 ) : 4'h0;
        blue   <= video_on ? (
 





((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 89 * px)) 

 

 

	|| ((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 88 * px)) 

 

	|| ((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 87 * px)) 

 

	|| ((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 86 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 85 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 84 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 83 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 83 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 82 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 82 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 81 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 81 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 80 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 80 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 79 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 78 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 77 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 76 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 75 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 74 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 73 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 72 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 71 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 70 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 69 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 68 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 67 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 66 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 65 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 64 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 63 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 62 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 61 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 60 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 59 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 59 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 58 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 58 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 57 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 57 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 56 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 56 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 55 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 55 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 54 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 54 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 53 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 53 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 52 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 52 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 51 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 51 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 50 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 50 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 49 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 49 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 48 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 48 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 47 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 47 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 47 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 46 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 46 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 46 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 45 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 45 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 45 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 44 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 44 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 44 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 43 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 42 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 41 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 40 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 39 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 38 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 37 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 36 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 35 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 34 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 33 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 32 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 31 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 30 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 29 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 28 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 27 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 26 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 25 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 24 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 23 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 22 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 21 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 20 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 19 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 19 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 18 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 18 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 17 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 17 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 16 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 16 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 15 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 15 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 14 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 14 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 13 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 13 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 12 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 12 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 11 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 11 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 10 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 10 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 9 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 9 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 8 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 8 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 7 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 7 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 6 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 6 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 5 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 5 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 4 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 4 * px)) 


? 4'hF:4'h0 ) : 4'h0;
        green   <= video_on ? (((pixel_x > mover + 14 * px) && (pixel_x <= mover + 19 * px) && (pixel_y == 375 - 67 * px))
	|| ((pixel_x > mover + 14 * px) && (pixel_x <= mover + 19 * px) && (pixel_y == 375 - 66 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 65 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 64 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 63 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 62 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 61 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 60 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 59 * px))
	|| ((pixel_x > mover + 28 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 59 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 58 * px))
	|| ((pixel_x > mover + 28 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 58 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 57 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 57 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 56 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 56 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 55 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 55 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 54 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 54 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 53 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 53 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 52 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 52 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 5 * px) && (pixel_y == 375 - 51 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 51 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 51 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 5 * px) && (pixel_y == 375 - 50 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 50 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 50 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 49 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 49 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 49 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 48 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 48 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 48 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 47 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 47 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 47 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 46 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 46 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 46 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 45 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 45 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 45 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 44 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 44 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 44 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 43 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 43 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 43 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 42 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 42 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 42 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 41 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 41 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 41 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 40 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 40 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 40 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 39 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 39 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 39 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 38 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 38 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 38 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 37 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 37 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 36 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 36 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 35 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 35 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 34 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 34 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 33 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 27 * px) && (pixel_y == 375 - 33 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 32 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 27 * px) && (pixel_y == 375 - 32 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 31 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 31 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 30 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 30 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 29 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 28 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 27 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 26 * px))
	|| ((pixel_x > mover + 6 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 25 * px))
	|| ((pixel_x > mover + 6 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 24 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 23 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 22 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 21 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 20 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 19 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 18 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 17 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 16 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 15 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 14 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 13 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 12 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 11 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 10 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 9 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 8 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 7 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 6 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 5 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 4 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 3 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 2 * px))? 4'hF:4'h0 ) : 4'h0;
        end
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        else if(state==3'b011)
        begin  
        red   <= video_on ? ((pixel_x>=0) && (pixel_x <= 639) && ( pixel_y>=375) && (pixel_y <= 380)? 4'hF:4'h0 ) : 4'h0;
        blue   <= video_on ? (
 


((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 89 * px)) 

 

 

	|| ((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 88 * px)) 

 

	|| ((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 87 * px)) 

 

	|| ((pixel_x> 25 + 48 * px) && (pixel_x<= 25 + 79 * px) && (pixel_y == mover_dino - 86 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 85 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 84 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 83 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 83 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 82 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 82 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 81 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 81 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 80 * px)) 

 

	|| ((pixel_x> 25 + 56 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 80 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 79 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 78 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 77 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 76 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 75 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 74 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 73 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 72 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 71 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 70 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 69 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 83 * px) && (pixel_y == mover_dino - 68 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 67 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 66 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 65 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 63 * px) && (pixel_y == mover_dino - 64 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 63 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 62 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 61 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 75 * px) && (pixel_y == mover_dino - 60 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 59 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 59 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 58 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 58 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 57 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 57 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 56 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 56 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 55 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 55 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 54 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 54 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 53 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 53 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 7 * px) && (pixel_y == mover_dino - 52 * px)) 

 

	|| ((pixel_x> 25 + 34 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 52 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 51 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 51 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 50 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 50 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 49 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 49 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 11 * px) && (pixel_y == mover_dino - 48 * px)) 

 

	|| ((pixel_x> 25 + 28 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 48 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 47 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 47 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 47 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 46 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 46 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 46 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 45 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 45 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 45 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 15 * px) && (pixel_y == mover_dino - 44 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 44 * px)) 

 

	|| ((pixel_x> 25 + 64 * px) && (pixel_x<= 25 + 67 * px) && (pixel_y == mover_dino - 44 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 43 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 42 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 41 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 40 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 39 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 38 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 37 * px)) 

 

	|| ((pixel_x> 25 + 4 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 36 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 35 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 59 * px) && (pixel_y == mover_dino - 34 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 33 * px)) 

 

	|| ((pixel_x> 25 + 8 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 32 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 31 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 30 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 29 * px)) 

 

	|| ((pixel_x> 25 + 12 * px) && (pixel_x<= 25 + 55 * px) && (pixel_y == mover_dino - 28 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 27 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 26 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 25 * px)) 

 

	|| ((pixel_x> 25 + 16 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 24 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 23 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 22 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 21 * px)) 

 

	|| ((pixel_x> 25 + 20 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 20 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 19 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 19 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 18 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 18 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 17 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 17 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 35 * px) && (pixel_y == mover_dino - 16 * px)) 

 

	|| ((pixel_x> 25 + 40 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 16 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 15 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 15 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 14 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 14 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 13 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 13 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 12 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 12 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 11 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 11 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 10 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 10 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 9 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 9 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 27 * px) && (pixel_y == mover_dino - 8 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 47 * px) && (pixel_y == mover_dino - 8 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 7 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 7 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 6 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 6 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 5 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 5 * px)) 

 

	|| ((pixel_x> 25 + 24 * px) && (pixel_x<= 25 + 31 * px) && (pixel_y == mover_dino - 4 * px)) 

 

	|| ((pixel_x> 25 + 44 * px) && (pixel_x<= 25 + 51 * px) && (pixel_y == mover_dino - 4 * px)) 


 ? 4'hF:4'h0 ) : 4'h0;
        green   <= video_on ? (((pixel_x > mover + 14 * px) && (pixel_x <= mover + 19 * px) && (pixel_y == 375 - 67 * px))
	|| ((pixel_x > mover + 14 * px) && (pixel_x <= mover + 19 * px) && (pixel_y == 375 - 66 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 65 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 64 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 63 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 62 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 61 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 60 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 59 * px))
	|| ((pixel_x > mover + 28 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 59 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 58 * px))
	|| ((pixel_x > mover + 28 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 58 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 57 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 57 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 56 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 56 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 55 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 55 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 54 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 54 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 53 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 53 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 52 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 52 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 5 * px) && (pixel_y == 375 - 51 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 51 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 51 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 5 * px) && (pixel_y == 375 - 50 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 50 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 50 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 49 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 49 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 49 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 48 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 48 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 48 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 47 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 47 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 47 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 46 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 46 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 46 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 45 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 45 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 45 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 44 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 44 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 44 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 43 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 43 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 43 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 42 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 42 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 42 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 41 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 41 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 41 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 40 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 40 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 40 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 39 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 39 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 39 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 38 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 38 * px))
	|| ((pixel_x > mover + 26 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 38 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 37 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 37 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 36 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 31 * px) && (pixel_y == 375 - 36 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 35 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 35 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 34 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 29 * px) && (pixel_y == 375 - 34 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 33 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 27 * px) && (pixel_y == 375 - 33 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 32 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 27 * px) && (pixel_y == 375 - 32 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 31 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 31 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 7 * px) && (pixel_y == 375 - 30 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 30 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 29 * px))
	|| ((pixel_x > mover + 2 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 28 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 27 * px))
	|| ((pixel_x > mover + 4 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 26 * px))
	|| ((pixel_x > mover + 6 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 25 * px))
	|| ((pixel_x > mover + 6 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 24 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 23 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 22 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 21 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 20 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 19 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 18 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 17 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 16 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 15 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 14 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 13 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 12 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 11 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 10 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 9 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 8 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 7 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 6 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 5 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 4 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 3 * px))
	|| ((pixel_x > mover + 12 * px) && (pixel_x <= mover + 21 * px) && (pixel_y == 375 - 2 * px))? 4'hF:4'h0 ) : 4'h0;
        end
        ///////////////////////////////////////////////////////////////////////
        else if(state==3'b100)
        begin  
         if (display) 
         begin
         red<=4'hF;
         blue<=4'hF;
         green<=4'h0;
         end
         
        
         else
         begin
         red<=4'h0;
         blue<=4'h0;
         green<=4'h0;
         end
         end
         ///////////////////////////////////
 else
 begin
 blue<=4'hF;
 end
      end
end
    
  

endmodule


module Seven_segment_LED_Display_Controller(
    input clock_100Mhz, // 100 Mhz clock source on Basys 3 FPGA
    input reset, // reset
    output reg [3:0] Anode_Activate, // anode signals of the 7-segment LED display
    output reg [6:0] LED_out// cathode patterns of the 7-segment LED display
    
    );
    reg [26:0] one_second_counter; // counter for generating 1 second clock enable
    wire one_second_enable;// one second enable for counting numbers
//    reg [15:0] displayed_number; // counting number to be displayed
    reg [15:0] displayed_number;
    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter; // 20-bit for creating 10.5ms refresh period or 380Hz refresh rate
             // the first 2 MSB bits for creating 4 LED-activating signals with 2.6ms digit period
    wire [1:0] LED_activating_counter; 
                 // count     0    ->  1  ->  2  ->  3
              // activates    LED1    LED2   LED3   LED4
             // and repeat
    always @(posedge clock_100Mhz or posedge reset)
    begin
        if(reset==1)
            one_second_counter <= 0;
        else begin
            if(one_second_counter>=99999999) 
                 one_second_counter <= 0;
            else
                one_second_counter <= one_second_counter + 1;
        end
    end 
    assign one_second_enable = (one_second_counter==99999999)?1:0;
   always @(posedge clock_100Mhz or posedge reset)
    begin
        if(reset==1)
            displayed_number <= 0;
        else if(one_second_enable==1)
            displayed_number <= displayed_number + 1;
    end
    always @(posedge clock_100Mhz or posedge reset)
    begin 
        if(reset==1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
    assign LED_activating_counter = refresh_counter[19:18];
    // anode activating signals for 4 LEDs, digit period of 2.6ms
    // decoder to generate anode signals 
    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD = displayed_number/1000;
            // the first digit of the 16-bit number
              end
        2'b01: begin
            Anode_Activate = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            LED_BCD = (displayed_number % 1000)/100;
            // the second digit of the 16-bit number
              end
        2'b10: begin
            Anode_Activate = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            LED_BCD = ((displayed_number % 1000)%100)/10;
            // the third digit of the 16-bit number
                end
        2'b11: begin
            Anode_Activate = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
            LED_BCD = ((displayed_number % 1000)%100)%10;
            // the fourth digit of the 16-bit number    
               end
        endcase
    end
    // Cathode patterns of the 7-segment LED display 
    always @(*)
    begin
        case(LED_BCD)
        4'b0000: LED_out = 7'b0000001; // "0"     
        4'b0001: LED_out = 7'b1001111; // "1" 
        4'b0010: LED_out = 7'b0010010; // "2" 
        4'b0011: LED_out = 7'b0000110; // "3" 
        4'b0100: LED_out = 7'b1001100; // "4" 
        4'b0101: LED_out = 7'b0100100; // "5" 
        4'b0110: LED_out = 7'b0100000; // "6" 
        4'b0111: LED_out = 7'b0001111; // "7" 
        4'b1000: LED_out = 7'b0000000; // "8"     
        4'b1001: LED_out = 7'b0000100; // "9" 
        default: LED_out = 7'b0000001; // "0"
        endcase
    end
 endmodule
//--------------------------------------------------------------------------------------------//

module Top_Level_Module(
input CLK,
input fsm_input_user,
input fsm_reset,
/////////////////////////////
output h_sync,
output v_sync,
output [3:0] red,
output [3:0] green,
output [3:0] blue,
output [6:0] LED_out,
output [3:0] Anode_Activate,
input score_reset
);

  
  wire clk_d,trig_V,VD_ON;
  wire [9:0]XL, YL;
  wire [9:0]hcount, Vcount;
  wire [2:0] state;
  wire [9:0]mover_dino;
  wire [9:0]mover; 
  
  
  
  
  
  //concatenate c1(.A(fsm_input_collision),.B(fsm_input_user),.Y(wire_1));
  clk_div C1(.clk(CLK),.clk_d(clk_d));
  h_counter H1(.clock(clk_d),.hcount(hcount),.trig_V(trig_V));
  V_counter V1(.clock(clk_d),.V_signal(trig_V),.Vcount(Vcount));
  VGA_sync VG1(.h_count(hcount),.v_count(Vcount),.h_sync(h_sync),.v_sync(v_sync),.video_on(VD_ON),.x_log(XL),.y_log(YL));
  FSM F1(.clk_div1(clk_d),.fsm_reset(fsm_reset),.fsm_input_user(fsm_input_user),.state(state),.mover_dino(mover_dino),.mover(mover));
  pixel_gen2 P1(.pixel_x(XL),.pixel_y(YL),.clk_div1(clk_d),.video_on(VD_ON),.red(red),.green(green),.blue(blue),.state(state),.mover_dino(mover_dino),.mover(mover));
  Seven_segment_LED_Display_Controller SedDisp(.clock_100Mhz(CLK),.reset(score_reset),.Anode_Activate(Anode_Activate),.LED_out(LED_out));
  
endmodule