--==============================================================================
--! @file ddr3_ctrl_wrapper.vhd
--==============================================================================

--! Standard library
library IEEE;
--! Standard packages
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
--! Specific packages

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- DDR3 Controller Wrapper
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--! @brief
--! DDR3 interface wrapper for MCB
--------------------------------------------------------------------------------
--! @details
--! DDR3 interface wrapper for Xilinx MCB (Memory Controller
--! Block). This core is based on the code generated by Xilinx CoreGen for
--! the MCB.
--------------------------------------------------------------------------------
--! @version
--! 0.1 | mc | 12.07.2011 | File creation and Doxygen comments
--!
--! @author
--! mc : Matthieu Cattin, CERN (BE-CO-HT)
--------------------------------------------------------------------------------


--==============================================================================
--! Entity declaration for ddr3_ctrl_wrapper
--==============================================================================
entity ddr3_ctrl_wrapper is

  generic(
    --! Core's clock period in ps
    g_MEMCLK_PERIOD      : integer := 3000;
    --! Core's reset polarity (1=active low, 0=active high)
    g_RST_ACT_LOW        : integer := 1;
    --! If TRUE, uses Xilinx calibration core (Input term, DQS centering)
    g_CALIB_SOFT_IP      : string  := "TRUE";
    --! User ports addresses maping (BANK_ROW_COLUMN or ROW_BANK_COLUMN)
    g_MEM_ADDR_ORDER     : string  := "ROW_BANK_COLUMN";
    --! Simulation mode
    g_SIMULATION         : string  := "FALSE";
    --! DDR3 data port width
    g_NUM_DQ_PINS        : integer := 16;
    --! DDR3 address port width
    g_MEM_ADDR_WIDTH     : integer := 14;
    --! DDR3 bank address width
    g_MEM_BANKADDR_WIDTH : integer := 3;
    --! Port 0 data mask size (8-bit granularity)
    g_P0_MASK_SIZE       : integer := 4;
    --! Port 0 data width
    g_P0_DATA_PORT_SIZE  : integer := 32;
    --! Port 0 byte address width
    g_P0_BYTE_ADDR_WIDTH : integer := 30;
    --! Port 1 data mask size (8-bit granularity)
    g_P1_MASK_SIZE       : integer := 4;
    --! Port 1 data width
    g_P1_DATA_PORT_SIZE  : integer := 32;
    --! Port 1 byte address width
    g_P1_BYTE_ADDR_WIDTH : integer := 30
    );

  port(
    ----------------------------------------------------------------------------
    -- Clock and reset
    ----------------------------------------------------------------------------
    --! Core's single ended clock input
    clk_i   : in std_logic;
    --! Core's reset input (active low)
    rst_n_i : in std_logic;

    ----------------------------------------------------------------------------
    -- Status
    ----------------------------------------------------------------------------
    --! Indicates end of calibration sequence at startup
    calib_done_o : out std_logic;

    ----------------------------------------------------------------------------
    -- DDR3 interface
    ----------------------------------------------------------------------------
    --! DDR3 data bus
    ddr3_dq_b     : inout std_logic_vector(g_NUM_DQ_PINS-1 downto 0);
    --! DDR3 address bus
    ddr3_a_o      : out   std_logic_vector(g_MEM_ADDR_WIDTH-1 downto 0);
    --! DDR3 bank address
    ddr3_ba_o     : out   std_logic_vector(g_MEM_BANKADDR_WIDTH-1 downto 0);
    --! DDR3 row address strobe
    ddr3_ras_n_o  : out   std_logic;
    --! DDR3 column address strobe
    ddr3_cas_n_o  : out   std_logic;
    --! DDR3 write enable
    ddr3_we_n_o   : out   std_logic;
    --! DDR3 on-die termination
    ddr3_odt_o    : out   std_logic;
    --! DDR3 reset
    ddr3_rst_n_o  : out   std_logic;
    --! DDR3 clock enable
    ddr3_cke_o    : out   std_logic;
    --! DDR3 lower byte data mask
    ddr3_dm_o     : out   std_logic;
    --! DDR3 upper byte data mask
    ddr3_udm_o    : out   std_logic;
    --! DDR3 lower byte data strobe (pos)
    ddr3_dqs_p_b  : inout std_logic;
    --! DDR3 lower byte data strobe (neg)
    ddr3_dqs_n_b  : inout std_logic;
    --! DDR3 upper byte data strobe (pos)
    ddr3_udqs_p_b : inout std_logic;
    --! DDR3 upper byte data strobe (pos)
    ddr3_udqs_n_b : inout std_logic;
    --! DDR3 clock (pos)
    ddr3_clk_p_o  : out   std_logic;
    --! DDR3 clock (neg)
    ddr3_clk_n_o  : out   std_logic;
    --! MCB internal termination calibration resistor
    ddr3_rzq_b    : inout std_logic;
    --! MCB internal termination calibration
    ddr3_zio_b    : inout std_logic;

    ----------------------------------------------------------------------------
    -- Port 0
    ----------------------------------------------------------------------------
    p0_cmd_clk_i       : in  std_logic;
    p0_cmd_en_i        : in  std_logic;
    p0_cmd_instr_i     : in  std_logic_vector(2 downto 0);
    p0_cmd_bl_i        : in  std_logic_vector(5 downto 0);
    p0_cmd_byte_addr_i : in  std_logic_vector(g_P0_BYTE_ADDR_WIDTH - 1 downto 0);
    p0_cmd_empty_o     : out std_logic;
    p0_cmd_full_o      : out std_logic;
    p0_wr_clk_i        : in  std_logic;
    p0_wr_en_i         : in  std_logic;
    p0_wr_mask_i       : in  std_logic_vector(g_P0_MASK_SIZE - 1 downto 0);
    p0_wr_data_i       : in  std_logic_vector(g_P0_DATA_PORT_SIZE - 1 downto 0);
    p0_wr_full_o       : out std_logic;
    p0_wr_empty_o      : out std_logic;
    p0_wr_count_o      : out std_logic_vector(6 downto 0);
    p0_wr_underrun_o   : out std_logic;
    p0_wr_error_o      : out std_logic;
    p0_rd_clk_i        : in  std_logic;
    p0_rd_en_i         : in  std_logic;
    p0_rd_data_o       : out std_logic_vector(g_P0_DATA_PORT_SIZE - 1 downto 0);
    p0_rd_full_o       : out std_logic;
    p0_rd_empty_o      : out std_logic;
    p0_rd_count_o      : out std_logic_vector(6 downto 0);
    p0_rd_overflow_o   : out std_logic;
    p0_rd_error_o      : out std_logic;

    ----------------------------------------------------------------------------
    -- Port 1
    ----------------------------------------------------------------------------
    p1_cmd_clk_i       : in  std_logic;
    p1_cmd_en_i        : in  std_logic;
    p1_cmd_instr_i     : in  std_logic_vector(2 downto 0);
    p1_cmd_bl_i        : in  std_logic_vector(5 downto 0);
    p1_cmd_byte_addr_i : in  std_logic_vector(g_P1_BYTE_ADDR_WIDTH - 1 downto 0);
    p1_cmd_empty_o     : out std_logic;
    p1_cmd_full_o      : out std_logic;
    p1_wr_clk_i        : in  std_logic;
    p1_wr_en_i         : in  std_logic;
    p1_wr_mask_i       : in  std_logic_vector(g_P1_MASK_SIZE - 1 downto 0);
    p1_wr_data_i       : in  std_logic_vector(g_P1_DATA_PORT_SIZE - 1 downto 0);
    p1_wr_full_o       : out std_logic;
    p1_wr_empty_o      : out std_logic;
    p1_wr_count_o      : out std_logic_vector(6 downto 0);
    p1_wr_underrun_o   : out std_logic;
    p1_wr_error_o      : out std_logic;
    p1_rd_clk_i        : in  std_logic;
    p1_rd_en_i         : in  std_logic;
    p1_rd_data_o       : out std_logic_vector(g_P1_DATA_PORT_SIZE - 1 downto 0);
    p1_rd_full_o       : out std_logic;
    p1_rd_empty_o      : out std_logic;
    p1_rd_count_o      : out std_logic_vector(6 downto 0);
    p1_rd_overflow_o   : out std_logic;
    p1_rd_error_o      : out std_logic
    );

end entity ddr3_ctrl_wrapper;



--==============================================================================
--! Architecure declaration for ddr3_ctrl_wrapper
--==============================================================================
architecture rtl of ddr3_ctrl_wrapper is

  ------------------------------------------------------------------------------
  -- Components declaration
  ------------------------------------------------------------------------------

  --! DDR controller component generated from Xilinx CoreGen
  component ddr_ctrl_bank3
    generic
      (
        C3_P0_MASK_SIZE       : integer := 4;
        C3_P0_DATA_PORT_SIZE  : integer := 32;
        C3_P1_MASK_SIZE       : integer := 4;
        C3_P1_DATA_PORT_SIZE  : integer := 32;
        C3_MEMCLK_PERIOD      : integer := 3000;
        C3_RST_ACT_LOW        : integer := 0;
        C3_INPUT_CLK_TYPE     : string  := "SINGLE_ENDED";
        C3_CALIB_SOFT_IP      : string  := "TRUE";
        C3_SIMULATION         : string  := "FALSE";
        DEBUG_EN              : integer := 0;
        C3_MEM_ADDR_ORDER     : string  := "ROW_BANK_COLUMN";
        C3_NUM_DQ_PINS        : integer := 16;
        C3_MEM_ADDR_WIDTH     : integer := 14;
        C3_MEM_BANKADDR_WIDTH : integer := 3
        );

    port
      (
        mcb3_dram_dq        : inout std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
        mcb3_dram_a         : out   std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
        mcb3_dram_ba        : out   std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
        mcb3_dram_ras_n     : out   std_logic;
        mcb3_dram_cas_n     : out   std_logic;
        mcb3_dram_we_n      : out   std_logic;
        mcb3_dram_odt       : out   std_logic;
        mcb3_dram_reset_n   : out   std_logic;
        mcb3_dram_cke       : out   std_logic;
        mcb3_dram_dm        : out   std_logic;
        mcb3_dram_udqs      : inout std_logic;
        mcb3_dram_udqs_n    : inout std_logic;
        mcb3_rzq            : inout std_logic;
        mcb3_zio            : inout std_logic;
        mcb3_dram_udm       : out   std_logic;
        c3_sys_clk_p        : in    std_logic;
        c3_sys_clk_n        : in    std_logic;
        c3_sys_clk          : in    std_logic;
        c3_sys_rst_n        : in    std_logic;
        c3_calib_done       : out   std_logic;
        c3_clk0             : out   std_logic;
        c3_rst0             : out   std_logic;
        mcb3_dram_dqs       : inout std_logic;
        mcb3_dram_dqs_n     : inout std_logic;
        mcb3_dram_ck        : out   std_logic;
        mcb3_dram_ck_n      : out   std_logic;
        c3_p0_cmd_clk       : in    std_logic;
        c3_p0_cmd_en        : in    std_logic;
        c3_p0_cmd_instr     : in    std_logic_vector(2 downto 0);
        c3_p0_cmd_bl        : in    std_logic_vector(5 downto 0);
        c3_p0_cmd_byte_addr : in    std_logic_vector(29 downto 0);
        c3_p0_cmd_empty     : out   std_logic;
        c3_p0_cmd_full      : out   std_logic;
        c3_p0_wr_clk        : in    std_logic;
        c3_p0_wr_en         : in    std_logic;
        c3_p0_wr_mask       : in    std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
        c3_p0_wr_data       : in    std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
        c3_p0_wr_full       : out   std_logic;
        c3_p0_wr_empty      : out   std_logic;
        c3_p0_wr_count      : out   std_logic_vector(6 downto 0);
        c3_p0_wr_underrun   : out   std_logic;
        c3_p0_wr_error      : out   std_logic;
        c3_p0_rd_clk        : in    std_logic;
        c3_p0_rd_en         : in    std_logic;
        c3_p0_rd_data       : out   std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
        c3_p0_rd_full       : out   std_logic;
        c3_p0_rd_empty      : out   std_logic;
        c3_p0_rd_count      : out   std_logic_vector(6 downto 0);
        c3_p0_rd_overflow   : out   std_logic;
        c3_p0_rd_error      : out   std_logic;
        c3_p1_cmd_clk       : in    std_logic;
        c3_p1_cmd_en        : in    std_logic;
        c3_p1_cmd_instr     : in    std_logic_vector(2 downto 0);
        c3_p1_cmd_bl        : in    std_logic_vector(5 downto 0);
        c3_p1_cmd_byte_addr : in    std_logic_vector(29 downto 0);
        c3_p1_cmd_empty     : out   std_logic;
        c3_p1_cmd_full      : out   std_logic;
        c3_p1_wr_clk        : in    std_logic;
        c3_p1_wr_en         : in    std_logic;
        c3_p1_wr_mask       : in    std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
        c3_p1_wr_data       : in    std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
        c3_p1_wr_full       : out   std_logic;
        c3_p1_wr_empty      : out   std_logic;
        c3_p1_wr_count      : out   std_logic_vector(6 downto 0);
        c3_p1_wr_underrun   : out   std_logic;
        c3_p1_wr_error      : out   std_logic;
        c3_p1_rd_clk        : in    std_logic;
        c3_p1_rd_en         : in    std_logic;
        c3_p1_rd_data       : out   std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
        c3_p1_rd_full       : out   std_logic;
        c3_p1_rd_empty      : out   std_logic;
        c3_p1_rd_count      : out   std_logic_vector(6 downto 0);
        c3_p1_rd_overflow   : out   std_logic;
        c3_p1_rd_error      : out   std_logic
        );
  end component ddr_ctrl_bank3;


--==============================================================================
--! Architecure begin
--==============================================================================
begin

  cmp_ddr_ctrl : ddr_ctrl_bank3
    generic map (
      C3_P0_MASK_SIZE       => g_P0_MASK_SIZE,
      C3_P0_DATA_PORT_SIZE  => g_P0_DATA_PORT_SIZE,
      C3_P1_MASK_SIZE       => g_P1_MASK_SIZE,
      C3_P1_DATA_PORT_SIZE  => g_P1_DATA_PORT_SIZE,
      C3_MEMCLK_PERIOD      => g_MEMCLK_PERIOD,
      C3_RST_ACT_LOW        => g_RST_ACT_LOW,
      C3_CALIB_SOFT_IP      => g_CALIB_SOFT_IP,
      C3_MEM_ADDR_ORDER     => g_MEM_ADDR_ORDER,
      C3_NUM_DQ_PINS        => g_NUM_DQ_PINS,
      C3_MEM_ADDR_WIDTH     => g_MEM_ADDR_WIDTH,
      C3_MEM_BANKADDR_WIDTH => g_MEM_BANKADDR_WIDTH,
      C3_SIMULATION         => g_SIMULATION
      )
    port map (
      c3_sys_clk    => clk_i,
      c3_sys_rst_n  => rst_n_i,
      c3_clk0       => open,
      c3_rst0       => open,
      c3_calib_done => calib_done_o,

      mcb3_dram_dq      => ddr3_dq_b,
      mcb3_dram_a       => ddr3_a_o,
      mcb3_dram_ba      => ddr3_ba_o,
      mcb3_dram_ras_n   => ddr3_ras_n_o,
      mcb3_dram_cas_n   => ddr3_cas_n_o,
      mcb3_dram_we_n    => ddr3_we_n_o,
      mcb3_dram_odt     => ddr3_odt_o,
      mcb3_dram_cke     => ddr3_cke_o,
      mcb3_dram_ck      => ddr3_clk_p_o,
      mcb3_dram_ck_n    => ddr3_clk_n_o,
      mcb3_dram_dqs     => ddr3_dqs_p_b,
      mcb3_dram_dqs_n   => ddr3_dqs_n_b,
      mcb3_dram_reset_n => ddr3_rst_n_o,
      mcb3_dram_udqs    => ddr3_udqs_p_b,  -- for X16 parts
      mcb3_dram_udqs_n  => ddr3_udqs_n_b,  -- for X16 parts
      mcb3_dram_udm     => ddr3_udm_o,     -- for X16 parts
      mcb3_dram_dm      => ddr3_dm_o,
      mcb3_rzq          => ddr3_rzq_b,
      mcb3_zio          => ddr3_zio_b,

      c3_p0_cmd_clk       => p0_cmd_clk_i,
      c3_p0_cmd_en        => p0_cmd_en_i,
      c3_p0_cmd_instr     => p0_cmd_instr_i,
      c3_p0_cmd_bl        => p0_cmd_bl_i,
      c3_p0_cmd_byte_addr => p0_cmd_byte_addr_i,
      c3_p0_cmd_empty     => p0_cmd_empty_o,
      c3_p0_cmd_full      => p0_cmd_full_o,
      c3_p0_wr_clk        => p0_wr_clk_i,
      c3_p0_wr_en         => p0_wr_en_i,
      c3_p0_wr_mask       => p0_wr_mask_i,
      c3_p0_wr_data       => p0_wr_data_i,
      c3_p0_wr_full       => p0_wr_full_o,
      c3_p0_wr_empty      => p0_wr_empty_o,
      c3_p0_wr_count      => p0_wr_count_o,
      c3_p0_wr_underrun   => p0_wr_underrun_o,
      c3_p0_wr_error      => p0_wr_error_o,
      c3_p0_rd_clk        => p0_rd_clk_i,
      c3_p0_rd_en         => p0_rd_en_i,
      c3_p0_rd_data       => p0_rd_data_o,
      c3_p0_rd_full       => p0_rd_full_o,
      c3_p0_rd_empty      => p0_rd_empty_o,
      c3_p0_rd_count      => p0_rd_count_o,
      c3_p0_rd_overflow   => p0_rd_overflow_o,
      c3_p0_rd_error      => p0_rd_error_o,

      c3_p1_cmd_clk       => p1_cmd_clk_i,
      c3_p1_cmd_en        => p1_cmd_en_i,
      c3_p1_cmd_instr     => p1_cmd_instr_i,
      c3_p1_cmd_bl        => p1_cmd_bl_i,
      c3_p1_cmd_byte_addr => p1_cmd_byte_addr_i,
      c3_p1_cmd_empty     => p1_cmd_empty_o,
      c3_p1_cmd_full      => p1_cmd_full_o,
      c3_p1_wr_clk        => p1_wr_clk_i,
      c3_p1_wr_en         => p1_wr_en_i,
      c3_p1_wr_mask       => p1_wr_mask_i,
      c3_p1_wr_data       => p1_wr_data_i,
      c3_p1_wr_full       => p1_wr_full_o,
      c3_p1_wr_empty      => p1_wr_empty_o,
      c3_p1_wr_count      => p1_wr_count_o,
      c3_p1_wr_underrun   => p1_wr_underrun_o,
      c3_p1_wr_error      => p1_wr_error_o,
      c3_p1_rd_clk        => p1_rd_clk_i,
      c3_p1_rd_en         => p1_rd_en_i,
      c3_p1_rd_data       => p1_rd_data_o,
      c3_p1_rd_full       => p1_rd_full_o,
      c3_p1_rd_empty      => p1_rd_empty_o,
      c3_p1_rd_count      => p1_rd_count_o,
      c3_p1_rd_overflow   => p1_rd_overflow_o,
      c3_p1_rd_error      => p1_rd_error_o
      );

end architecture rtl;
--==============================================================================
--! Architecure end
--==============================================================================

