// Simple Module Ram with no parameter,
// the data length is a single byte

module byte_sram(
    input logic sram_clk,
    input logic sram_ares,
    input logic wr_enable,
    input logic rd_enable,
    input logic [6:0] ram_index,
    input logic [7:0] sram_data_in,
    output logic [7:0] sram_data_out);

  // memory element
  logic [7:0] memory [2**7]; // 128 byte element stored in the SRAM

  // internal signals
  logic [7:0] data_read;

  // SRAM indexing for reset
  // main process
  always_ff @(posedge sram_clk or posedge sram_ares) begin
    if(sram_ares) begin
      // Reset the memory no operation is captured under reset
      foreach(memory[jj])
        memory[jj] = 8'h0;
      // reset the data out
      data_read = '0;
    end
    else begin
      // Write should be prioritized value read is always the most updated one
      if(wr_enable & (~rd_enable)) begin
        // Write operation is deploying the index
        memory[ram_index] <= sram_data_in;
        data_read <= '0;
      end
      else if(rd_enable & (~wr_enable)) begin
        data_read <= memory[ram_index];
      end
      else begin
        // both the enables signals are set to 0
        data_read <= '0;
      end
    end
  end

  // give the output
  assign sram_data_out = rd_enable ? data_read : 8'h0;
endmodule
