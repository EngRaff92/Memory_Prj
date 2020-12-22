// This is the To test bench for the simple SRAM element

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

  // Module instance
  byte_sram u_sram_byte (.*);

  // Make a reset pulse and specify dump file
  initial begin
     $dumpfile("dump.vcd");
     $dumpvars(0);

     # 0  sram_ares = 0;
     # 10 sram_ares = 1;
     # 4  sram_ares = 0;
     # 36 sram_ares = 1;
     # 4  sram_ares = 0;
     # 6  $finish;
  end

  // Drive signals

  // assertion checking
  initial begin

  end


  // Make a regular pulsing clock.
  always #1 sram_clk = !sram_clk;
endmodule
