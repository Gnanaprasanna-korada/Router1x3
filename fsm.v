`timescale 1ns / 1ps



module fsm(clk,rst,pkt_valid,busy,parity_done,data_in,soft_reset0,soft_reset1,soft_reset2,low_packet_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,
detect_addr,lfd_state,laf_state,full_state,write_enb_reg,rst_int_reg,ld_state,fifo_full   );
input clk,rst,pkt_valid,parity_done,soft_reset0,soft_reset1,soft_reset2,low_packet_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,fifo_full;
input [1:0]data_in;
output busy,detect_addr,lfd_state,laf_state,full_state,write_enb_reg,rst_int_reg,ld_state ;
reg [1:0]temp;
parameter decode_address=3'b000,load_first_data=3'b001,load_data=3'b010,fifo_full_state=3'b011,load_after_full=3'b100,
load_parity=3'b101,check_parity_error=3'b110,wait_till_empty=3'b111;
reg [2:0]p_s,n_s;

//temp logic

always @(posedge clk)
begin
if(!rst)
temp<=0;
else if(detect_addr)
temp<=data_in;
else
temp<=temp;
end

//present_state logic

always @(posedge clk)
begin
if(!rst)
p_s<=decode_address;
else if((soft_reset0&&temp==0)||(soft_reset1&&temp==1)||(soft_reset2&&temp==2))
p_s<=decode_address;
else
p_s<=n_s;
end

//fsm

always @(*)
begin
case(p_s)
decode_address:
begin
 if((pkt_valid&&(data_in[1:0]==0)&&fifo_empty_0)||(pkt_valid&&(data_in[1:0]==1)&&fifo_empty_1)||(pkt_valid&&(data_in[1:0]==2)&&fifo_empty_2))
 n_s<=load_first_data;
 else if((pkt_valid&&(data_in[1:0]==0)&&!fifo_empty_0)||(pkt_valid&&(data_in[1:0]==1)&&!fifo_empty_1)||(pkt_valid&&(data_in[1:0]==2)&&!fifo_empty_2))
 n_s<=wait_till_empty;
 else
 n_s<=decode_address;
end
load_first_data:
 n_s<=load_data;
load_data:
begin
if(fifo_full)
n_s<=fifo_full_state;
else if(!fifo_full&&!pkt_valid)
n_s<=load_parity;
else
n_s<=load_data;
end
fifo_full_state:
if(!fifo_full)
n_s<=load_after_full;
else if(fifo_full)
n_s<=fifo_full_state;
load_after_full:
begin
if(!parity_done&&!low_packet_valid)
n_s<=load_data;
else if(!parity_done&&low_packet_valid)
n_s<=load_parity;
else if(parity_done)
n_s<=decode_address;
else
n_s<=load_after_full;
end
load_parity:
n_s<=check_parity_error;
check_parity_error:
if(!fifo_full)
n_s<=decode_address;
else 
n_s<=n_s;
wait_till_empty:
begin
if((fifo_empty_0&&(detect_addr==0))||(fifo_empty_1&&(detect_addr==1))||(fifo_empty_2&&(detect_addr==2)))
n_s<=load_first_data;
else
n_s<=wait_till_empty;
end
default :n_s<=decode_address;
endcase
end

//outputs logic

assign busy=((p_s==load_first_data)||(p_s==fifo_full_state)||(p_s==load_after_full)||(p_s==load_parity)||(p_s==check_parity_error)
||(p_s==wait_till_empty))?1'b1:1'b0;
assign detect_addr=(p_s==decode_address)?1'b1:1'b0;
assign ld_state=(p_s==load_data)?1'b1:1'b0;
assign laf_state=(p_s==load_after_full)?1'b1:1'b0;
assign full_state=(p_s==fifo_full_state)?1'b1:1'b0;
assign write_enb_reg=((p_s==load_data)||(p_s==load_after_full)||(p_s==load_parity))?1'b1:1'b0;
assign rst_int_reg=(p_s==check_parity_error)?1'b1:1'b0;
assign lfd_state=(p_s==load_first_data)?1'b1:1'b0;
endmodule
