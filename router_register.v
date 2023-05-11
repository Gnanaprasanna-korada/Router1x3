`timescale 1ns / 1ps
module router_register( clk,rst,pkt_valid,data_in,fifo_full,rst_int_reg,detect_addr,ld_state,laf_state,full_state,lfd_state,parity_done,
low_packet_valid,err,dout);
input clk,rst,pkt_valid,fifo_full,detect_addr,rst_int_reg,ld_state,laf_state,full_state,lfd_state;
input [1:0] data_in;
output reg err;
output reg parity_done,low_packet_valid;
output reg [7:0] dout;
reg [7:0] hld_header,fifo_full_byte,internal_parity,pkt_parity;

//low packet valid
always @(posedge clk)
begin
if(!rst ||rst_int_reg)
low_packet_valid<=0;
else if (!pkt_valid &&(ld_state))
low_packet_valid<=1;
else low_packet_valid<=0;
end

//hold_header
always @(posedge clk)
if(pkt_valid&&detect_addr)
hld_header<=data_in;

//fifo _full_byte
always@(posedge clk)
if(fifo_full &&ld_state)
fifo_full_byte<=data_in;

//parity done
always@(posedge clk)
begin
if(!rst||detect_addr)
parity_done<=0;
else if(!pkt_valid &&!fifo_full&&ld_state)
parity_done<=1;
else if(!low_packet_valid && laf_state&&!parity_done)
parity_done<=1;
else 
parity_done<=0;
end

// data_out
always @(posedge clk) begin
if(!rst)
dout<=8'bz;
else if(ld_state&&!fifo_full)
dout<=data_in;
else if(lfd_state)
dout<=hld_header;
else if(laf_state)
dout<=fifo_full_byte;
end

//error
always @(posedge clk)
begin
if(!rst)
err<=0;
else if (parity_done)
begin
 if (internal_parity==pkt_parity)
err<=0;
else
err<=1;
end
else
err<=0;
end

//packet_parity
always@(posedge clk)
begin
if(!rst)
pkt_parity<=8'dz;
else if(!pkt_valid && ld_state&& !fifo_full)
pkt_parity<=data_in;
else if(laf_state&&!parity_done&&low_packet_valid)
pkt_parity<=fifo_full_byte;
else
pkt_parity<=pkt_parity;
end

//internal_parity
always @(posedge clk)
begin
if(!rst)
internal_parity<=0;
else if(lfd_state&&pkt_valid)
internal_parity<=internal_parity^hld_header;
else if(ld_state &&!full_state && pkt_valid)
internal_parity<=internal_parity^data_in;
else if(laf_state && !low_packet_valid)
internal_parity<=internal_parity^fifo_full_byte;
else
internal_parity<=internal_parity;
end
endmodule

