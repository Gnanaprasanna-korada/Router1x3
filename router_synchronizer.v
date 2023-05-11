`timescale 1ns / 1ps
module router_synchronizer(input detect_addr,write_enb_reg,clock,resetn,read_enb_0,read_enb_1,read_enb_2, full_0,full_1,full_2,empty_0,empty_1,empty_2,
 input [1:0]data_in,
output vld_out_0,vld_out_1,vld_out_2,output reg fifo_full,soft_reset_0,soft_reset_1,soft_reset_2,output reg [2:0]write_en );
reg [4:0]count_0,count_1,count_2;
reg [1:0] temp;

//data_in logic
 always@(posedge clock)
 begin
 if(!resetn)
 temp<=2'bzz;
 else if(detect_addr)
 temp<=data_in;
 else
 temp<=2'bzz;
 end
 
 
 //fifo_full
 always @(*)
 begin
 if(full_0||full_1||full_2)
 fifo_full<=1'b1;
 else
 fifo_full<=1'b0;
 end
 
 //write enable
 always @(*)
 begin
 if(write_enb_reg)
 case(temp)
 2'b00:write_en=001;
 2'b01:write_en=010;
 2'b10:write_en=100;
 endcase
 else
 write_en=0;
 end
 
 //valid_out_logic
 assign vld_out_0=(!empty_0)?1'b1:1'b0;
  assign vld_out_1=(!empty_1)?1'b1:1'b0;
   assign vld_out_2=(!empty_2)?1'b1:1'b0;
   
   //soft rest logic
   always @(*)
      begin
      if(!resetn)
      begin
      soft_reset_0<=1'b0;
      count_0<=5'b0; end
      else if(vld_out_0)begin
      if(!read_enb_0)begin
      if(count_0==5'b11110)begin
         soft_reset_0<=1'b1;
         count_0<=0;end
         else begin
      count_0<=count_0+1;
      soft_reset_0<=0;end end
      end
      end
      
      always @(*)
         begin
         if(!resetn)
         begin
         soft_reset_1<=1'b0;
         count_0<=5'b0; end
         else if(!empty_1)begin
         if(!read_enb_1)begin
         if(count_1==5'b11110)begin
            soft_reset_1<=1'b1;
            count_1<=0;end
            else begin
         count_1<=count_1+1;
         soft_reset_1<=0;end end
         end
         end
         
         always @(*)
            begin
            if(!resetn)
            begin
            soft_reset_2<=1'b0;
            count_2<=5'b0; end
            else if(!empty_2)begin
            if(!read_enb_2)begin
            if(count_2==5'b11110)begin
               soft_reset_2<=1'b1;
               count_2<=0;end
               else begin
            count_2<=count_2+1;
            soft_reset_2<=0;end end
            end
            end
endmodule
