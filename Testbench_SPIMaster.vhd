------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 11/11/2024
-- Module Name: SPIMaster
-- Description:
--      SPI Master allowing Write/Read operations on slave devices.
--		Features:
--          - CPOL Configuration
--          - CPHA Configuration
--          - Slave Select Polarity (active Low or High)
--          - 2-Byte Delay Interval (0 to 7 SPI Clock Cycles)
--          - Byte Number Configuration
--          - Daisy-Chain (Slaves MUST support this feature)
--
-- Usage:
--      The Ready signal indicates no operation is on going and the SPI Master is waiting operation.
--		The Busy signal indicates operation is on going.
--      Reset input can be trigger at any time to reset the SPI Master to the IDLE state.
--		1. Set all necessary inputs
--			* Byte Number (number of byte required to write/read)
--			* Byte Delay (number of SPI SCLK Clock Cycles between 2 bytes to write/read)
--			* Slave Select (set to '1' the Slave Select Line to enable)
--			* Data to Write
--      2. Asserts Start input. The Ready signal is de-asserted and the Busy signal is asserted.
--		3. SPI Master re-asserts the Ready signal at the end of transmission (Master is ready for a new transmission)
--		4. The read value is available when its validity signal is asserted
--
-- Generics
--      input_clock: Module Input Clock Frequency
--      spi_clock: SPI Serial Clock Frequency
--      cpol: SPI Clock Polarity ('0': SCLK IDLE at Low, '1': SCLK IDLE at High)
--      cpha: SPI Clock Phase ('0': Data valid on Leading/First Edge of SCLK, '1': Data valid on Trailing/Second Edge of SCLK)
--      ss_polarity: SPI Slave Select Polarity ('0': active Low, '1': active High)
--      ss_length: Number of Chip/Slave Select Lines
--      max_data_register_length: Maximum SPI Data Register Length in bits
--
-- Ports
--		Input 	-	i_clock: Module Input Clock
--		Input 	-	i_reset: Reset ('0': No Reset, '1': Reset)
--		Input 	-	i_byte_number: SPI Byte Number during the Transmission
--		Input 	-	i_byte_delay: SPI Delay between 2-Byte Transmission (0 to 7 SPI Clock Cycles)
--		Input 	-	i_slave_select: SPI Slave Selection ('0': Not Selected, '1': Selected)
--		Input 	-	i_start: Start SPI Transmission ('0': No Start, '1': Start)
--		Input 	-	i_write_value: Data to Write
--		Output 	-	o_read_value: Data Read from Slave
--		Output 	-	o_read_value_valid: Validity of the Data Read ('0': Not Valid, '1': Valid)
--		Output 	-	o_ready: Ready State of SPI Master ('0': Not Ready, '1': Ready)
--		Output 	-	o_busy: Busy State of SPI Master ('0': Not Busy, '1': Busy)
--		Output 	-	o_sclk: SPI Serial Clock
--		Output 	-	o_mosi: SPI Master Output Slave Input Data line
--		Input 	-	i_miso: SPI Master Input Slave Output Data line
--		Output 	-	o_ss: SPI Slave Select Line (inverted ss_polarity: Not Selected, ss_polarity: Selected)
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Testbench_SPIMaster is
end Testbench_SPIMaster;

architecture Behavioral of Testbench_SPIMaster is

COMPONENT SPIMaster is

GENERIC(
    input_clock: INTEGER := 12_000_000;
    spi_clock: INTEGER := 100_000;
    cpol: STD_LOGIC := '0';
    cpha: STD_LOGIC := '0';
    ss_polarity: STD_LOGIC := '0';
    ss_length: INTEGER := 1;
    max_data_register_length: INTEGER := 8
);

PORT(
    i_clock: IN STD_LOGIC;
    i_reset: IN STD_LOGIC;
    i_byte_number: IN INTEGER range 0 to 2*(max_data_register_length/8);
    i_byte_delay: IN INTEGER range 0 to 7;
    i_slave_select: IN STD_LOGIC_VECTOR(ss_length-1 downto 0);
    i_start: IN STD_LOGIC;
    i_write_value: IN STD_LOGIC_VECTOR(max_data_register_length-1 downto 0);
	o_read_value: OUT STD_LOGIC_VECTOR(max_data_register_length-1 downto 0);
    o_read_value_valid: OUT STD_LOGIC;
    o_ready: OUT STD_LOGIC;
    o_busy: OUT STD_LOGIC;
    o_sclk: OUT STD_LOGIC;
    o_mosi: OUT STD_LOGIC;
    i_miso: IN STD_LOGIC;
    o_ss: OUT STD_LOGIC_VECTOR(ss_length-1 downto 0)
);

END COMPONENT;

signal clock_12M: STD_LOGIC := '0';
signal reset: STD_LOGIC := '0';
signal start: STD_LOGIC := '0';
signal ready: STD_LOGIC := '0';
signal busy: STD_LOGIC := '0';
signal read_value_valid: STD_LOGIC := '0';
signal read_value: STD_LOGIC_VECTOR(7 downto 0):= (others => '0');
signal sclk: STD_LOGIC := '1';
signal mosi: STD_LOGIC := '1';
signal miso: STD_LOGIC := '1';
signal ss: STD_LOGIC_VECTOR(0 downto 0):= (others => '0');


begin

-- Clock 12 MHz
clock_12M <= not(clock_12M) after 41.6667 ns;

-- Reset
reset <= '1', '0' after 50 ns;

-- Start
start <= '0', '1' after 111 us, '0' after 113 us, '1' after 600 us, '0' after 620 us;

-- MISO
miso <= '0',
        -- Read 1
    	'1' after 600.213135 us,
		'1' after 620.129961 us,
		'0' after 630.130041 us,
		'0' after 640.130121 us,
		'1' after 650.130201 us,
		'0' after 660.130281 us,
		'1' after 670.130361 us,
		'1' after 680.130441 us,
		'0' after 690.130521 us;

uut: SPIMaster
    GENERIC map(
        input_clock => 12_000_000,
        spi_clock => 100_000,
        cpol => '0',
        cpha => '0',
        ss_polarity => '0',
        ss_length => 1,
        max_data_register_length => 8
    )
    
    PORT map(
        i_clock => clock_12M,
        i_reset => reset,
        i_byte_number => 0,
        i_byte_delay => 0,
        i_slave_select => "1",
        i_start => start,
        i_write_value => "10100101",
        o_read_value => read_value,
        o_read_value_valid => read_value_valid,
        o_ready => ready,
        o_busy => busy,
        o_sclk => sclk,
        o_mosi => mosi,
        i_miso => miso,
        o_ss => ss);

end Behavioral;
