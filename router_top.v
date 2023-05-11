`timescale 1ns / 1ps
module router_top(clock,resetn,pkt_valid,read_enb_0,read_enb_1,read_enb_2,data_in,
				    busy,err,vld_out_0,vld_out_1,vld_out_2,data_out_0,data_out_1,data_out_2);
  
  input [7:0]data_in;
  input pkt_valid,clock,resetn,read_enb_0,read_enb_1,read_enb_2;
  output [7:0]data_out_0,data_out_1,data_out_2;
  output vld_out_0,vld_out_1,vld_out_2,err,busy;
	
	wire soft_reset_0,full_0,empty_0,soft_reset_1,full_1,empty_1,soft_reset_2,full_2,empty_2,
         fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,
         parity_done,low_packet_valid,write_enb_reg;
	wire [2:0]write_enb;
	wire [7:0]d_in;
	
    //-------fifo instantiation-----
    
    
	 fifo fifo_0(
   clock,resetn,write_enb[0],soft_reset_0,lfd_state,read_enb_0,d_in,data_out_0,full_0,empty_0
       );
		 fifo fifo_1(
         clock,resetn,write_enb[1],soft_reset_1,lfd_state,read_enb_1,d_in,data_out_1,full_1,empty_1
             );		   
	 fifo fifo_2(
               clock,resetn,write_enb[2],soft_reset_2,lfd_state,read_enb_2,d_in,data_out_2,full_2,empty_2
                   );
					   
		
    //-------register instantiation-----	
    router_register register( clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,
    low_packet_valid,err,d_in);			  
				  
    				
    //-------synchronizer instantiation-----

  router_synchronizer sync_block( detect_add,write_enb_reg,clock,resetn,read_enb_0,read_enb_1,read_enb_2, full_0,full_1,full_2,empty_0,empty_1,empty_2,    
    data_in[1:0],
  vld_out_0,vld_out_1,vld_out_2, fifo_full,soft_reset_0,soft_reset_1,soft_reset_2 ,write_enb );
							
							 
    //-------fsm instantiation-----
  fsm fsm_1(clock,resetn,pkt_valid,busy,parity_done,data_in[1:0],soft_reset_0,soft_reset_1,soft_reset_2,low_packet_valid,empty_0,empty_1,empty_2,
    detect_add,lfd_state,laf_state,full_state,write_enb_reg,rst_int_reg,ld_state,fifo_full   );  
	
endmodule

