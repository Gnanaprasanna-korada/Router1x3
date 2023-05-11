`timescale 1ns / 1ps


module fifo(
clk,rst,wr_en,sft_rst,lfd_state,rd_en,data_in,data_out,full,empty
    );
    input clk,rst,wr_en,rd_en,sft_rst,lfd_state;
    input [7:0]data_in;
    output reg full,empty;
    output reg [7:0]data_out;
    reg [4:0]rd_ptr,wr_ptr;
    reg [5:0]count;
    reg temp;
    reg [8:0]mem[15:0];
    reg [4:0] increment=0;
    integer i;
    //lfd_state logic
    always @(posedge clk)
    begin
    if(!rst)
    temp<=0;
    else
    temp<=lfd_state;
    end
    
    //pointer logic
    always @(posedge clk)
    begin
    if(!rst||sft_rst) begin
    wr_ptr<=0;
    rd_ptr<=0;end
    else if(wr_en&&!full)
    wr_ptr<=wr_ptr+1;
    else if(rd_en&&!empty)
    rd_ptr<=rd_ptr+1;
    else begin
    wr_ptr<=wr_ptr;rd_ptr<=rd_ptr;
    end
    end
    
    //increment logic
    always @(posedge clk)
    begin
    if(!rst||sft_rst)increment<=0;
    else if(wr_en&&!full)increment<=increment+1;
    else if(rd_en&&!empty)increment<=increment-1;
    else increment<=increment;
    end
    always@(increment)
    begin
    empty<=(increment==5'd0)?1'b1:1'b0;
    full<=(increment==5'd16)?1'b1:1'b0;
    end
    //write logic
    always @(posedge clk)
    begin
    if(!rst||sft_rst)
    for( i=0;i<16;i=i+1)
    mem[i]<=0;
    if(wr_en&&!full)
    begin
    mem[wr_ptr][7:0]<=data_in;
    mem[wr_ptr][8]<=temp;
    end
    else mem[wr_ptr]<=mem[wr_ptr];
    end
    
    //read logic
    always@(posedge clk)
    begin
    if(!rst)
    data_out<=8'd0;
    else if(sft_rst)
    data_out<=8'dz;
    else if(rd_en &&!empty)
    data_out<=mem[rd_ptr];
    else data_out<=data_out;
    end
    
    //counter
    always @(posedge clk)
    begin
    if(rd_en&& !empty)
    begin
    if(mem[rd_ptr][8])count<=mem[rd_ptr][7:2]+1'b1;
    else if(count!=0)count<=count-1;
    end
    else
    count<=count;
    end
endmodule
