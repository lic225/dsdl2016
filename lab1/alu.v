module alu( A , B , op , show , C , overflow , segs );
  input [5:0] A;
  input [5:0] B;
  input [1:0] op;
  // 2'b00 : add16, 2'b01 : sub16, 2'b10 : mul16, 2'b11 : div16

  input show;
  // 0 : A B , 1 : res

  output [11:0] C;
  output overflow;
  output [47:0] segs;

  `include"ALU_tasks.v"

  reg [15:0] myA , myB , myC , myRem;

  reg [11:0] C;
  reg overflow;
  reg [41:0] segs;

  parameter SEG = 7;
  
  always @(A, B, op, show) begin
    C = 0;
    overflow = 0;
    segs = ~42'b0;
    // $display( "in alu!! %4d" , $signed(A) );
    from6to16( A , myA );
    from6to16( B , myB );

    case( op )
      2'b00 : add16( myA , myB , myC );
      2'b01 : sub16( myA , myB , myC );
      2'b10 : mul16( myA , myB , myC );
      2'b11 : div16( myA , myB , myC , myRem );
    endcase

    if( show == 1'b0 ) begin
      C[6+:6] = A;
      C[0+:6]  = B;
      draw6( A , segs[3*SEG +: 3*SEG] );
      draw6( B , segs[0*SEG  +: 3*SEG] );
    end
    else begin
      case( op )
        2'b10 : begin
          from16to12( myC , C , overflow );
          draw12( C , segs[0*SEG +: 5*SEG] );
        end
        2'b11 : begin
          from16to6( myC , C[6 +: 6] , overflow );
          from16to6( myRem , C[0 +: 6] , overflow );
          draw6( C[6 +: 6] , segs[3*SEG +: 3*SEG] );
          draw6( C[0+:6] , segs[0*SEG +: 3*SEG] );
        end
        default : begin
          from16to6( myC , C[6+:6] , overflow );
          draw6( C[6+:6] , segs[0*SEG +: 3*SEG] );
        end
      endcase
    end

    // $display( "result %4d\n" , $signed(C[11:6]) );


  end


endmodule
