`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2018 02:55:55 PM
// Design Name: 
// Module Name: dithering
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dithering(
    input logic  hc,vc,SW,
    input logic [23:0] entrada,
    output logic [23:0] salida
    );
    
    logic [1:0] rms,gms,bms;
    logic [3:0] CER,CEG,CEB;
    logic [3:0] CR,CG,CB;
    
    localparam a=2'd0;
    localparam b=2'd2;
    localparam c=2'd3;
    localparam d=2'd1;
    
    assign {CER,CEG,CEB} = {entrada[23:20],entrada[15:12],entrada[7:4]};
    assign {rms,gms,bms} = {entrada[19:18],entrada[11:10],entrada[3:2]};
    assign salida = {CR,entrada[19:16],CG,entrada[11:8],CB,entrada[3:0]}; 
    
    
    always_comb begin
        case(SW)
        1'b1:begin
                 if(CER==4'd15)
                    CR = CER;
                 else begin
                 if ((hc==1'b1) && (vc==1'b1)) begin
                    if(rms>2'd0)
                        CR = CER + 4'd1;
                     else
                        CR = CER;
                        end
                        
                else if ((hc==1'b0) && (vc==1'b1)) begin
                    if(rms>2'd2) 
                        CR = CER + 4'd1;
                     else
                        CR = CER;
                        end
                else if ((hc==1'b1) && (vc==1'b0)) begin
                    if(rms>2'd3) 
                        CR = CER + 4'd1;
                     else
                        CR = CER;
                        end        
                else  begin
                    if(rms>2'd1) 
                        CR = CER + 4'd1;
                     else
                        CR = CER;
                        end 
                end
               end
       1'b0: begin
                CR = CER;
                end
       endcase         
       end        
                
    always_comb begin
           case(SW)
           1'b1:begin
                    if (CEG==4'd15)
                        CG = CEG;
                    else begin
                    if ((hc==1'b1) && (vc==1'b1)) begin
                       if(gms>2'd0)
                           CG = CEG + 4'd1;
                        else
                           CG = CEG;
                           end
                           
                   else if ((hc==1'b0) && (vc==1'b1)) begin
                       if(gms>2'd2) 
                           CG = CEG + 4'd1;
                        else
                           CG = CEG;
                           end
                   else if ((hc==1'b1) && (vc==1'b0)) begin
                       if(gms>2'd3) 
                           CG = CEG + 4'd1;
                        else
                           CG = CEG;
                           end        
                   else  begin
                       if(gms>2'd1) 
                           CG = CEG + 4'd1;
                        else
                           CG = CEG;
                           end 
                     end      
                  end
                  
          1'b0: begin
                   CG = CEG;
                   end
          endcase         
          end
              
    always_comb begin
         case(SW)
         1'b1:begin
                  if (CEB==4'd15)
                        CB = CEB;
                  else begin
                  if ((hc==1'b1) && (vc==1'b1)) begin
                     if(bms>2'd0)
                         CB = CEB + 4'd1;
                      else
                         CB = CEB;
                         end
                         
                 else if ((hc==1'b0) && (vc==1'b1)) begin
                     if(bms>2'd2) 
                         CB = CEB + 4'd1;
                      else
                         CB = CEB;
                         end
                 else if ((hc==1'b1) && (vc==1'b0)) begin
                     if(bms>2'd3) 
                         CB = CEB + 4'd1;
                      else
                         CB = CEB;
                         end        
                 else  begin
                     if(bms>2'd1) 
                         CB = CEB + 4'd1;
                      else
                         CB = CEB;
                         end 
                end
                end
        1'b0: begin
                 CB = CEB;
                 end
        endcase         
        end      
          
          
endmodule