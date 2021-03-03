//file name: sync_fifo.v
//function : sync fifo 
//author   : HateHanzo
module sync_fifo(
        clk   , 
        rst_n , 
        wen   , 
        ren   , 
        wdata , 
       
        rdata , 
        empty , 
        full  
);

//parametr
parameter DLY         = 1              ;
parameter WIDTH_FIFO  = 8              ;
parameter ADDR_FIFO   = 4              ;
parameter DEPTH_FIFO  = 1 << ADDR_FIFO ;

//input output
input                      clk    ;
input                      rst_n  ;
input                      wen    ;
input                      ren    ;
input  [WIDTH_FIFO-1:0]    wdata  ;

output [WIDTH_FIFO-1:0]    rdata  ;
output                     empty  ;
output                     full   ;

//-----------------------------
//--signal
//-----------------------------
reg    [WIDTH_FIFO-1:0]    rdata               ;
reg    [ADDR_FIFO:0]       wbin                ; 
reg    [ADDR_FIFO:0]       rbin                ;
reg    [WIDTH_FIFO-1:0]    mem[DEPTH_FIFO-1:0] ;


//-----------------------------
//--main circuit
//-----------------------------

//------------------
//write logic
//------------------

wire wbin_next = ( wen && (!full) ) ? (wbin + {{{ADDR_FIFO}{1'b0}},1'b1}) : wbin ;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		wbin  <= #DLY { {ADDR_FIFO+1}{1'b0} } ;
	else
		wbin  <= #DLY wbin_next  ;
end

//write data
always@(posedge clk)
  if(wen && (!full))
    mem[wbin[ADDR_FIFO-1:0]] <= #DLY wdata;
  else ;


//gen full,the MSB of wbin and rbin are different,the test are the same
wire full = (wbin[ADDR_FIFO]^rbin[ADDR_FIFO]) &&
            (wbin[ADDR_FIFO-1:0] == rbin[ADDR_FIFO-1:0]);

//-----------------
//read logic
//-----------------

wire rbin_next = ( ren && (!empty) ) ? (rbin + {{{ADDR_FIFO}{1'b0}},1'b1}) : rbin ;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		rbin  <= #DLY { {ADDR_FIFO+1}{1'b0} } ;
	else 
		rbin  <= #DLY rbin_next  ;
end


//read data
always@(posedge clk)
  if(ren && (!empty))
    rdata <= #DLY mem[rbin[ADDR_FIFO-1:0]] ;
  else ;

//gen empty,the wbin equal rbin
wire empty = (wbin == rbin);


endmodule





