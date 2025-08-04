/*module router_fifo_tb();
		reg clock,resetn,write_enb,soft_reset,read_enb,lfd_state;
		reg [7:0] data_in;
		wire [7:0] data_out;
		wire empty,full;
		integer k;

		router_fifo dut(clock,resetn,write_enb,
				soft_reset,read_enb,data_in,lfd_state,
				data_out,empty,full);

		always
				  #10 clock=~clock;

		task initialize;
				  {clock,resetn,write_enb,read_enb,data_in,lfd_state,soft_reset}=0;
		endtask

		task reset_dut;
				  begin
							 @(negedge clock)
							 	resetn=1'b0;
							 @(negedge clock)
							 	resetn=1'b1;
				  end
		endtask

		task inputs;
				  input [7:0] i;
				  begin
						@(negedge clock)
							data_in=i;
				  end
		endtask

		initial
			begin
					  initialize;
					  fork
					  reset_dut;
					  @(negedge clock) write_enb=1'b1;
					  @(negedge clock) lfd_state=1'b1;
					  begin
							repeat(3) @(negedge clock) 
							lfd_state=1'b0;
						end	
					  stimulus(8'b01010101);
					  		for(k=0;k<22;k=k+1)
									  inputs({$random}%256);
							#50;
					  read_enb=1'b1;
					  write_enb=1'b0;
					  join
			end
endmodule*/












module router_fifo_tb;

  reg clock, resetn, write_enb, soft_reset, read_enb, lfd_state;
  reg [7:0] data_in;
  wire full, empty;
  wire [7:0] data_out;
  integer i, count;
  reg k;

  router_fifo DUT (clock,resetn,write_enb,
				soft_reset,read_enb,data_in,lfd_state,
				data_out,empty,full);
  

  task initialize;
    begin
      {clock, resetn, write_enb, soft_reset, read_enb, lfd_state} = 0;
      data_in = 0;
		count = 0;
    end
  endtask

  always #5 clock = ~clock;

  task stimulus;
    input [7:0] i;
    begin
      @(negedge clock);
      data_in = i;
    end
  endtask

  always begin
	  #1;
	if(full) disable not_full;
  end

  initial begin
    //monitor;
    initialize;
	 k=1;
    fork
      @(negedge clock) resetn = 1;
      @(negedge clock) write_enb = 1;
      @(negedge clock) lfd_state = 1;
      begin
      	repeat(2) @(negedge clock);
      	lfd_state = 0;
      end
      begin	
      	stimulus(8'b01010101);
			while(k) begin
				if(count == 22) k = 0;
				else if(~full) begin : not_full
					write_enb = 1;
					read_enb = 0;
					stimulus({$random} % 256);
					count = count + 1;
		 		end else begin
					#0.1;
					write_enb = 0; 
					read_enb = 1;
				end
      	end
		end
    join
	 read_enb = 1;
    #200 $finish;
  end

endmodule


