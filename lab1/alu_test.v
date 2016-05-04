module alu_test;
  wire [5:0] wA , wB;
  wire [1:0] wop;
  wire wshow;
  wire [11:0] C;
  wire overflow;

  reg [5:0] A , B;
  reg [1:0] op;
  reg show;

  integer i , j , res, t, remainder;

  assign wA = A;
  assign wB = B;
  assign wop = op;
  assign wshow = show;

  alu myalu( wA , wB , wop , wshow , C , overflow );

  initial begin
    show  = 1;
    for( i=-32 ; i < 32 ; i = i+1 ) begin
      for( j=-32 ; j < 32 ; j = j+1 ) begin
        A = i[5:0];
        B = j[5:0];

        op = 2'b00;
        #10;
        t = $signed(C[11:6]);
        if(~overflow && i+j != t)
          $display("%4d + %4d = %4d", $signed(A), $signed(B), $signed(C[11:6]));
        
        op = 2'b01;
        #10;
        t = $signed(C[11:6]);
        if(~overflow && i-j != t)
          $display("%4d - %4d = %4d", $signed(A), $signed(B), $signed(C[11:6]));
          
        op = 2'b10;
        #10;
        t = $signed(C);
        if(~overflow && i*j != t)
          $display("%4d * %4d = %8d", $signed(A), $signed(B), $signed(C));
        
        if( i >= 0 && j > 0 ) begin
          op = 2'b11;
          #10;
          t = $signed(C[11:6]);
          remainder = $signed(C[5:0]);
          if(~overflow && (i/j != t || i % j != remainder) )
            $display("%4d / %4d = %4d %4d", $signed(A), $signed(B), $signed(C[11:6]) , $signed(C[5:0]));           
        end

      end
    end
  end

endmodule