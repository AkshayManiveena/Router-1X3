//Testbench for Topmodule of Router
module router_top_tb;

  reg clock, resetn, read_enb_0, read_enb_1, read_enb_2, pkt_valid;
  reg [7:0] data_in;
  wire valid_out_0, valid_out_1, valid_out_2, error, busy;
  wire [7:0] data_out_0, data_out_1, data_out_2;
  integer i;
  
  event pkt_17,pkt_random;

  router_top DUT (
      clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,valid_out_0,
			valid_out_1,valid_out_2,error,busy);
 

  task initialize;
    begin
      {clock, resetn, read_enb_0, read_enb_1, read_enb_2, pkt_valid, data_in} = 0;
    end
  endtask

  always #5 clock = ~clock;
	
  task reset_dut;
		  begin 
		  @(negedge clock)
		  resetn = 1'b0;
		  @(negedge clock)
		  resetn = 1'b1;
		  end
  endtask


  task pkt_gen_lt14;
		  reg[7:0] payload_data,parity,header;
		  reg[5:0] payload_len;
		  reg[1:0] addr;

		  begin
				  @(negedge clock)
				  	wait(~busy);
				  @(negedge clock)
				  	payload_len=6'd12;
					addr = 2'b01;
					header = {payload_len,addr};
					parity = 0;
					data_in = header;
					pkt_valid = 1'b1;
				  	parity = parity ^ header;
				  @(negedge clock)
				  	wait(~busy)
						for(i=0;i<payload_len;i=i+1)
						begin
								@(negedge clock)
									wait(~busy)
										payload_data = {$random}%256;
										data_in = payload_data;
										parity = parity ^ data_in;
						end
				  @(negedge clock)
				  	wait(~busy)
						pkt_valid = 1'b0;
						data_in = parity;
		  end
	endtask

	 task pkt_gen_eq14;
		  reg[7:0] payload_data,parity,header;
		  reg[5:0] payload_len;
		  reg[1:0] addr;

		  begin
				  @(negedge clock)
				  	wait(~busy);
				  @(negedge clock)
				  	payload_len=6'd14;
					addr = 2'd0;
					header = {payload_len,addr};
					parity = 0;
					data_in = header;
					pkt_valid = 1'b1;
				  	parity = parity ^ header;
				  @(negedge clock)
				  	wait(~busy)
						for(i=0;i<payload_len;i=i+1)
						begin
								@(negedge clock)
									wait(~busy)
										payload_data = {$random}%256;
										data_in = payload_data;
										parity = parity ^ data_in;
						end
				  @(negedge clock)
				  	wait(~busy)
						pkt_valid = 1'b0;
						data_in = parity;
		  end
	endtask


	 task pkt_gen_eq16;
		  reg[7:0] payload_data,parity,header;
		  reg[5:0] payload_len;
		  reg[1:0] addr;

		  begin
				  @(negedge clock)
				  	wait(~busy);
				  @(negedge clock)
				  	payload_len=6'd16;
					addr = 2'd2;
					header = {payload_len,addr};
					parity = 0;
					data_in = header;
					pkt_valid = 1'b1;
				  	parity = parity ^ header;
				  @(negedge clock)
				  	wait(~busy)
						for(i=0;i<payload_len;i=i+1)
						begin
								@(negedge clock)
									wait(~busy)
										payload_data = {$random}%256;
										data_in = payload_data;
										parity = parity ^ data_in;
						end
				  @(negedge clock)
				  	wait(~busy)
						pkt_valid = 1'b0;
						data_in = parity;
		  end
	endtask
	
	
	initial
		begin
				@pkt_17;
				read_enb_1=1;
		end
	initial
		begin
				@pkt_random;
				read_enb_0=1;
		end
	task pkt_gen_eq17;
		reg[7:0] payload_data,parity,header;
		  reg[5:0] payload_len;
		  reg[1:0] addr;

		  begin
				  @(negedge clock)
				  	wait(~busy);
				  @(negedge clock)
				  //->pkt_17;
				  	payload_len=6'd35;
					addr = 2'd1;
					header = {payload_len,addr};
					parity = 0;
					data_in = header;
					pkt_valid = 1'b1;
				  	parity = parity ^ header;
				  @(negedge clock)
				  	wait(~busy)
						for(i=0;i<payload_len;i=i+1)
						begin
								@(negedge clock)
								if(i==15) begin
									->pkt_17;
								end	
								wait(~busy)
										payload_data = {$random}%256;
										data_in = payload_data;
										parity = parity ^ data_in;
						end
				  @(negedge clock)
				  	wait(~busy)
						pkt_valid = 1'b0;
						data_in = parity;
		  end
	endtask
	
	task pkt_gen_random;
		reg[7:0] payload_data,parity,header;
		  reg[5:0] payload_len;
		  reg[1:0] addr;

		  begin
				  @(negedge clock)
				  	wait(~busy);
				  @(negedge clock)
				  ->pkt_random;
				  	payload_len={$random}%63;
					addr = 2'd0;
					header = {payload_len,addr};
					parity = 0;
					data_in = header;
					pkt_valid = 1'b1;
				  	parity = parity ^ header;
				  @(negedge clock)
				  	wait(~busy)
						for(i=0;i<payload_len;i=i+1)
						begin
								@(negedge clock)	
								wait(~busy)
										payload_data = {$random}%256;
										data_in = payload_data;
										parity = parity ^ data_in;
						end
				  @(negedge clock)
				  	wait(~busy)
						pkt_valid = 1'b0;
						data_in = parity;
		  end
	endtask
	

	initial
		begin
				initialize;
				/*reset_dut;
				@(negedge clock)
					pkt_gen_lt14;
				@(negedge clock)
					read_enb_1 = 1'b1;
				wait(~valid_out_1);
					@(negedge clock)
						read_enb_1 = 1'b0;
			
			//Packet equal to 14
				@(negedge clock)
					reset_dut;
				@(negedge clock)
					pkt_gen_eq14;
				@(negedge clock)
					read_enb_0 = 1'b1;
				wait(~valid_out_0);
					@(negedge clock)
						read_enb_0 = 1'b0;
				
				
				//Packet equqal to 16
				@(negedge clock)
				reset_dut;
				@(negedge clock)
					pkt_gen_eq16;
				@(negedge clock)
					read_enb_2 = 1'b1;
				wait(~valid_out_2);
					@(negedge clock)
						read_enb_2 = 1'b0;/*/
				//Packet length 17
				reset_dut;
				@(negedge clock)
					pkt_gen_eq17;
				wait(~valid_out_1);
					@(negedge clock)
						read_enb_1 = 1'b0;
				//Random packet
				reset_dut;
				@(negedge clock)
					pkt_gen_random;
				wait(~valid_out_0);
					@(negedge clock)
						read_enb_0 = 1'b0;
				end
	endmodule

  /*task stimulus;
    input [7:0] data;
    begin
      @(negedge clock) data_in = data;
    end
  endtask

  task monitor;
    begin
      $dumpfile("router_top_tb.vcd");
      $dumpvars(0, router_top_tb);
    end
  endtask

  always @(negedge clock) begin
    if(valid_out_1) begin
       read_enb_1 = 1;
    end else read_enb_1 = 0;
  end

  initial begin
    monitor;
    initialize;
    @(negedge clock) resetn = 1;
    pkt_valid = 1;
    data_in = {6'd12,2'd1};
    @(negedge clock);
    for (i = 0; i < 12; i = i + 1) begin
      stimulus({$random} % 256);
    end
    @(negedge clock) pkt_valid = 0;
    data_in = 8'd125;
    #300 $finish;
  end*/

//endmodule


