module test_bench(A, B);
  output [15:0] A;
  output [15:0] B;
  reg [15:0] A;
  reg [15:0] B;
  
  initial begin
    A = -16'sd31;
    B = -16'sd17;
    #1000;
    A = 16'sd31;
    B = 16'sd31;
    #1000;
    A = -16'sd17;
    B = 16'sd3;
    #1000;
    A = 16'sd17;
    B = -16'sd17;
    #1000;
    A = -16'sd14;
    B = -16'sd13;
  end
endmodule
