module synchroniser_2ff #(parameter width = 5)(
  input wire clk, reset_n,
  input wire [width-1:0] data_in,
  output reg [width-1:0] data_out
  );
  
  reg [width-1:0] stage1; // internal state
  
  always @(posedge clk or negedge reset_n)
    begin
      if(!reset_n)
        begin
          stage1 <= {width{1'b0}};
          data_out <= {width{1'b0}};
        end
      else
        begin
          stage1 <= data_in;
          data_out <= stage1;
        end
    end
endmodule