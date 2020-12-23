// This is the To test bench for the simple SRAM element

`timescale 1ns/1ns

// Main module test
module sram_tb_top;
  // Important parameter
  parameter CLOCK_FREQ = 100; // MHZ

  // Local variables
  bit sram_clk;
  logic sram_ares;
  logic wr_enable;
  logic rd_enable;
  logic [6:0] ram_index;
  logic [7:0] sram_data_in;
  logic [7:0] sram_data_out;

  // Checking variables
  logic [7:0] read_data;

  // test bench knobs
  bit sva_disable = 1; // temp due to race condition
  bit debug;

  // Module instance
  byte_sram u_sram_byte (.*);

  // Make a reset pulse and specify dump file
  initial begin
     $dumpfile("dump.vcd");
     $dumpvars();
    // Assert reset
     # 0  sram_ares = 0;
     # 10 sram_ares = 1;
     # 4  sram_ares = 0;
     // End
     # 700 $finish;
  end

  // Drive signals
  initial begin
    // Start only when reset is deasserted
    @(posedge sram_ares);
    @(negedge sram_ares);
    for(int i=0; i<(2**$bits(ram_index)); i++) begin
      // issue a write
      sram_write(i,i);
      // issue a read
      sram_read(i,read_data);
      // check
      if(read_data != i) begin
        $error("Data read from index: %0h is not euqal to expected data: %0h, data is:%0h at time: %0t",i,i,read_data,$time());
      end
    end
    // Create the stall condition
    rd_enable = 0;
    wr_enable = 0;
    repeat(2) @(posedge sram_clk);
    rd_enable = 1;
    wr_enable = 1;
    repeat(2) @(posedge sram_clk);
  end

  // assertion checking
  initial begin
    // Start only when we are out of reset
    @(posedge sram_ares);
    @(negedge sram_ares);
    forever begin
      @(posedge sram_clk);
      if(~sva_disable) begin
        if(~(rd_enable ^ wr_enable)) begin
          assert (sram_data_out == '0)
          else $error("SRAM read error in stall condition data is not 0");
        end
      end
    end
  end

  // Make a regular pulsing clock.
  always #1 sram_clk = !sram_clk;

  // Task used to write and read
  task sram_write(  input bit [6:0] index,
                          bit [7:0] wdata);
    // since this is a write se assume the wr_en is 1 rd_en
    if(sram_ares == 1) begin
      $display("SRAM under reset dropping write at time %0t for index: %0d",$time(),index);
    end
    else begin
      wr_enable = 1;
      @(negedge sram_clk); // Avoid races by deplyoing #step delay
      ram_index = index;
      sram_data_in = wdata;
      @(posedge sram_clk); // Here the SRAM samples data
      @(negedge sram_clk); // Here data is applied and stored
    end
    // display data and index at specific time
    if(debug)
      $display("Data written to index: %0d is: %0h at time: %0t",index,wdata,$time());
    // Bus release
    wr_enable = 0;
  endtask

  task sram_read(   input bit [6:0] index,
                    output logic [7:0] rdata);
    // since is a read we assume the rd_enable to be 1
    if(sram_ares == 1) begin
      $display("SRAM under reset dropping read at time %0t for index: %0d",$time(),index);
    end
    else begin
      rd_enable = 1;
      @(negedge sram_clk); // Avoid races by deplyoing #step delay
      ram_index = index;
      @(posedge sram_clk); // get data on the next valid active edge
      rdata = sram_data_out;
    end
    // display data and index at specific time
    if(debug)
      $display("Data read from index: %0d is: %0h at time: %0t",index,rdata,$time());
      // Bus release
    rd_enable = 0;
  endtask
endmodule
