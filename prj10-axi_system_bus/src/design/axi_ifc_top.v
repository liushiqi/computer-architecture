/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

module axi_ifc_top #(parameter SIMULATION=1'b0)
(
    input         resetn, 
    input         clk,

    //------gpio-------
    output [15:0] led,
    output [1 :0] led_rg0,
    output [1 :0] led_rg1,
    output [7 :0] num_csn,
    output [6 :0] num_a_g,
    input  [7 :0] switch, 
    output [3 :0] btn_key_col,
    input  [3 :0] btn_key_row,
    input  [1 :0] btn_step
);
//debug signals
wire [31:0] debug_wb_pc;
wire [3 :0] debug_wb_rf_wen;
wire [4 :0] debug_wb_rf_wnum;
wire [31:0] debug_wb_rf_wdata;

//clk and resetn
wire cpu_clk;
wire timer_clk;
reg cpu_resetn;
assign cpu_clk   = clk;
assign timer_clk = clk;
always @(posedge cpu_clk)
begin
    cpu_resetn <= resetn;
end

//cpu inst sram-like
wire        cpu_inst_req;
wire        cpu_inst_wr;
wire [1 :0] cpu_inst_size;
wire [31:0] cpu_inst_addr;
wire [31:0] cpu_inst_wdata;
wire [31:0] cpu_inst_rdata;
wire        cpu_inst_addr_ok;
wire        cpu_inst_data_ok;

//cpu data sram-like
wire        cpu_data_req;
wire        cpu_data_wr;
wire [1 :0] cpu_data_size;
wire [31:0] cpu_data_addr;
wire [31:0] cpu_data_wdata;
wire [31:0] cpu_data_rdata;
wire        cpu_data_addr_ok;
wire        cpu_data_data_ok;

//axi
//ar
wire [3 :0] axi_arid   ;
wire [31:0] axi_araddr ;
wire [7 :0] axi_arlen  ;
wire [2 :0] axi_arsize ;
wire [1 :0] axi_arburst;
wire [1 :0] axi_arlock ;
wire [3 :0] axi_arcache;
wire [2 :0] axi_arprot ;
wire        axi_arvalid;
wire        axi_arready;
//r
wire [3 :0] axi_rid    ;
wire [31:0] axi_rdata  ;
wire [1 :0] axi_rresp  ;
wire        axi_rlast  ;
wire        axi_rvalid ;
wire        axi_rready ;
//aw
wire [3 :0] axi_awid   ;
wire [31:0] axi_awaddr ;
wire [7 :0] axi_awlen  ;
wire [2 :0] axi_awsize ;
wire [1 :0] axi_awburst;
wire [1 :0] axi_awlock ;
wire [3 :0] axi_awcache;
wire [2 :0] axi_awprot ;
wire        axi_awvalid;
wire        axi_awready;
//w
wire [3 :0] axi_wid    ;
wire [31:0] axi_wdata  ;
wire [3 :0] axi_wstrb  ;
wire        axi_wlast  ;
wire        axi_wvalid ;
wire        axi_wready ;
//b
wire [3 :0] axi_bid    ;
wire [1 :0] axi_bresp  ;
wire        axi_bvalid ;
wire        axi_bready ;

//from confreg
wire [4:0] ram_random_mask;
wire cpu_simu_flag;
//to confreg
wire        display_num_valid;
wire [31:0] display_num_data;

//virtual cpu
virtual_cpu u_virtual_cpu (
    .clk           ( cpu_clk          ),
    .resetn        ( cpu_resetn       ),

    //inst sram-like 
    .inst_req      ( cpu_inst_req     ),
    .inst_wr       ( cpu_inst_wr      ),
    .inst_size     ( cpu_inst_size    ),
    .inst_addr     ( cpu_inst_addr    ),
    .inst_wdata    ( cpu_inst_wdata   ),
    .inst_rdata    ( cpu_inst_rdata   ),
    .inst_addr_ok  ( cpu_inst_addr_ok ),
    .inst_data_ok  ( cpu_inst_data_ok ),
    
    //data sram-like 
    .data_req      ( cpu_data_req     ),
    .data_wr       ( cpu_data_wr      ),
    .data_size     ( cpu_data_size    ),
    .data_addr     ( cpu_data_addr    ),
    .data_wdata    ( cpu_data_wdata   ),
    .data_rdata    ( cpu_data_rdata   ),
    .data_addr_ok  ( cpu_data_addr_ok ),
    .data_data_ok  ( cpu_data_data_ok ),

    //from confreg
    .cpu_simu_flag     ( cpu_simu_flag     ),
    .display_num_valid ( display_num_valid ),
    .display_num_data  ( display_num_data  )
);


//sram-like to axi bridge
cpu_axi_interface u_axi_ifc(
    .clock         ( cpu_clk          ),
    .reset_        ( cpu_resetn       ),

    //inst sram-like 
    .instruction_ram_request(cpu_inst_req),
    .instruction_ram_write(cpu_inst_wr),
    .instruction_ram_size(cpu_inst_size),
    .instruction_ram_address(cpu_inst_addr),
    .instruction_ram_write_data(cpu_inst_wdata),
    .instruction_ram_read_data(cpu_inst_rdata),
    .instruction_ram_address_ready(cpu_inst_addr_ok),
    .instruction_ram_data_ready(cpu_inst_data_ok),
    
    //data sram-like 
    .data_ram_request(cpu_data_req),
    .data_ram_write(cpu_data_wr),
    .data_ram_size(cpu_data_size),
    .data_ram_address(cpu_data_addr),
    .data_ram_write_data(cpu_data_wdata),
    .data_ram_read_data(cpu_data_rdata),
    .data_ram_address_ready(cpu_data_addr_ok),
    .data_ram_data_ready(cpu_data_data_ok),

    //axi
    //ar
    .axi_read_address_id(axi_arid),
    .axi_read_address(axi_araddr),
    .axi_read_address_length(axi_arlen),
    .axi_read_address_size(axi_arsize),
    .axi_read_address_burst(axi_arburst),
    .axi_read_address_lock(axi_arlock),
    .axi_read_address_cache(axi_arcache),
    .axi_read_address_protection(axi_arprot),
    .axi_read_address_valid(axi_arvalid),
    .axi_read_address_ready(axi_arready),
    //r
    .axi_read_data_id(axi_rid),
    .axi_read_data(axi_rdata),
    .axi_read_data_response(axi_rresp),
    .axi_read_data_last(axi_rlast),
    .axi_read_data_valid(axi_rvalid),
    .axi_read_data_ready(axi_rready),
    //aw
    .axi_write_address_id(axi_awid),
    .axi_write_address(axi_awaddr),
    .axi_write_address_length(axi_awlen),
    .axi_write_address_size(axi_awsize),
    .axi_write_address_burst(axi_awburst),
    .axi_write_address_lock(axi_awlock),
    .axi_write_address_cache(axi_awcache),
    .axi_write_address_protection(axi_awprot),
    .axi_write_address_valid(axi_awvalid),
    .axi_write_address_ready(axi_awready),
    //w
    .axi_write_data_id(axi_wid),
    .axi_write_data(axi_wdata),
    .axi_write_data_strobe(axi_wstrb),
    .axi_write_data_last(axi_wlast),
    .axi_write_data_valid(axi_wvalid),
    .axi_write_data_ready(axi_wready),
    //b
    .axi_write_responce_id(axi_bid),
    .axi_write_responce(axi_bresp),
    .axi_write_responce_valid(axi_bvalid),
    .axi_write_responce_ready(axi_bready)
);

//ram
axi_wrap_ram u_axi_ram
(
    .aclk          ( cpu_clk          ),
    .aresetn       ( cpu_resetn       ),
    //ar
    .axi_arid      ( axi_arid         ),
    .axi_araddr    ( axi_araddr       ),
    .axi_arlen     ( axi_arlen        ),
    .axi_arsize    ( axi_arsize       ),
    .axi_arburst   ( axi_arburst      ),
    .axi_arlock    ( axi_arlock       ),
    .axi_arcache   ( axi_arcache      ),
    .axi_arprot    ( axi_arprot       ),
    .axi_arvalid   ( axi_arvalid      ),
    .axi_arready   ( axi_arready      ),
    //r              
    .axi_rid       ( axi_rid          ),
    .axi_rdata     ( axi_rdata        ),
    .axi_rresp     ( axi_rresp        ),
    .axi_rlast     ( axi_rlast        ),
    .axi_rvalid    ( axi_rvalid       ),
    .axi_rready    ( axi_rready       ),
    //aw           
    .axi_awid      ( axi_awid         ),
    .axi_awaddr    ( axi_awaddr       ),
    .axi_awlen     ( axi_awlen        ),
    .axi_awsize    ( axi_awsize       ),
    .axi_awburst   ( axi_awburst      ),
    .axi_awlock    ( axi_awlock       ),
    .axi_awcache   ( axi_awcache      ),
    .axi_awprot    ( axi_awprot       ),
    .axi_awvalid   ( axi_awvalid      ),
    .axi_awready   ( axi_awready      ),
    //w          
    .axi_wid       ( axi_wid          ),
    .axi_wdata     ( axi_wdata        ),
    .axi_wstrb     ( axi_wstrb        ),
    .axi_wlast     ( axi_wlast        ),
    .axi_wvalid    ( axi_wvalid       ),
    .axi_wready    ( axi_wready       ),
    //b              
    .axi_bid       ( axi_bid          ),
    .axi_bresp     ( axi_bresp        ),
    .axi_bvalid    ( axi_bvalid       ),
    .axi_bready    ( axi_bready       ),

    //random mask
    .ram_random_mask ( ram_random_mask )
);

//conf
wire        conf_en    = 1'b0;
wire [3 :0] conf_wen   = 4'd0;
wire [31:0] conf_addr  = 32'd0;
wire [31:0] conf_wdata = 32'd0;
wire [31:0] conf_rdata;

//confreg
confreg #(.SIMULATION(SIMULATION)) confreg
(
    .clk         ( cpu_clk    ),  // i, 1   
    .timer_clk   ( timer_clk  ),  // i, 1   
    .resetn      ( cpu_resetn ),  // i, 1    

    .conf_en     ( conf_en    ),  // i, 1      
    .conf_wen    ( conf_wen   ),  // i, 4      
    .conf_addr   ( conf_addr  ),  // i, 32        
    .conf_wdata  ( conf_wdata ),  // i, 32         
    .conf_rdata  ( conf_rdata ),  // o, 32         

    .ram_random_mask   ( ram_random_mask   ),
    .cpu_simu_flag     ( cpu_simu_flag     ),
    .display_num_valid ( display_num_valid ),
    .display_num_data  ( display_num_data  ),

    .led         ( led        ),  // o, 16   
    .led_rg0     ( led_rg0    ),  // o, 2      
    .led_rg1     ( led_rg1    ),  // o, 2      
    .num_csn     ( num_csn    ),  // o, 8      
    .num_a_g     ( num_a_g    ),  // o, 7      
    .switch      ( switch     ),  // i, 8     
    .btn_key_col ( btn_key_col),  // o, 4          
    .btn_key_row ( btn_key_row),  // i, 4           
    .btn_step    ( btn_step   )   // i, 2   
);

endmodule

