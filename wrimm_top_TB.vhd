--Propery of Tecphos Inc.  See License.txt for license details
--Latest version of all project files available at http://opencores.org/project,wrimm
--See WrimmManual.pdf for the Wishbone Datasheet and implementation details.
--See wrimm subversion project for version history

library Wrimm;
  use Wrimm.WrimmPackage.all;
library ieee;
  use ieee.NUMERIC_STD.all;
  use ieee.std_logic_1164.all;

entity wrimm_top_tb is
end wrimm_top_tb;

architecture TB_ARCHITECTURE of wrimm_top_tb is
  component wrimm_top
  port(
    WishboneClock       : in  std_logic;
    WishboneReset       : out std_logic;
    MasterPStrobe       : in  std_logic;
    MasterPWrEn         : in  std_logic;
    MasterPCyc          : in  std_logic;
    MasterPAddr         : in  WbAddrType;
    MasterPDataToSlave  : in  WbDataType;
    MasterPAck          : out std_logic;
    MasterPErr          : out std_logic;
    MasterPRty          : out std_logic;
    MasterPDataFrSlave  : out WbDataType;
    MasterQStrobe       : in  std_logic;
    MasterQWrEn         : in  std_logic;
    MasterQCyc          : in  std_logic;
    MasterQAddr         : in  WbAddrType;
    MasterQDataToSlave  : in  WbDataType;
    MasterQAck          : out std_logic;
    MasterQErr          : out std_logic;
    MasterQRty          : out std_logic;
    MasterQDataFrSlave  : out WbDataType;
    StatusRegA          : in  std_logic_vector(0 to 7);
    StatusRegB          : in  std_logic_vector(0 to 7);
    StatusRegC          : in  std_logic_vector(0 to 7);
    SettingRegX         : out std_logic_vector(0 to 7);
    SettingRstX         : in  std_logic;
    SettingRegY         : out std_logic_vector(0 to 7);
    SettingRstY         : in  std_logic;
    SettingRegZ         : out std_logic_vector(0 to 7);
    SettingRstZ         : in  std_logic;
    TriggerRegR         : out std_logic;
    TriggerClrR         : in  std_logic;
    TriggerRegS         : out std_logic;
    TriggerClrS         : in  std_logic;
    TriggerRegT         : out std_logic;
    TriggerClrT         : in  std_logic;
    rstZ                : in  std_logic);
  end component;

  signal WishboneClock        : std_logic;
  signal MasterPStrobe        : std_logic;
  signal MasterPWrEn          : std_logic;
  signal MasterPCyc           : std_logic;
  signal MasterPAddr          : WbAddrType;
  signal MasterPDataToSlave   : WbDataType;
  signal MasterQStrobe        : std_logic;
  signal MasterQWrEn          : std_logic;
  signal MasterQCyc           : std_logic;
  signal MasterQAddr          : WbAddrType;
  signal MasterQDataToSlave   : WbDataType;
  signal StatusRegA           : std_logic_vector(0 to 7);
  signal StatusRegB           : std_logic_vector(0 to 7);
  signal StatusRegC           : std_logic_vector(0 to 7);
  signal SettingRstX          : std_logic;
  signal SettingRstY          : std_logic;
  signal SettingRstZ          : std_logic;
  signal TriggerClrR          : std_logic;
  signal TriggerClrS          : std_logic;
  signal TriggerClrT          : std_logic;
  signal rstZ                 : std_logic;
  signal WishboneReset        : std_logic;
  signal MasterPAck           : std_logic;
  signal MasterPErr           : std_logic;
  signal MasterPRty           : std_logic;
  signal MasterPDataFrSlave   : WbDataType;
  signal MasterQAck           : std_logic;
  signal MasterQErr           : std_logic;
  signal MasterQRty           : std_logic;
  signal MasterQDataFrSlave   : WbDataType;
  signal SettingRegX          : std_logic_vector(0 to 7);
  signal SettingRegY          : std_logic_vector(0 to 7);
  signal SettingRegZ          : std_logic_vector(0 to 7);
  signal TriggerRegR          : std_logic;
  signal TriggerRegS          : std_logic;
  signal TriggerRegT          : std_logic;

  constant clkPeriod          : time := 0.01 us; --100 MHz

begin
  UUT : wrimm_top
    port map (
      WishboneClock         => WishboneClock,
      WishboneReset         => WishboneReset,
      MasterPStrobe         => MasterPStrobe,
      MasterPWrEn           => MasterPWrEn,
      MasterPCyc            => MasterPCyc,
      MasterPAddr           => MasterPAddr,
      MasterPDataToSlave    => MasterPDataToSlave,
      MasterPAck            => MasterPAck,
      MasterPErr            => MasterPErr,
      MasterPRty            => MasterPRty,
      MasterPDataFrSlave    => MasterPDataFrSlave,
      MasterQStrobe         => MasterQStrobe,
      MasterQWrEn           => MasterQWrEn,
      MasterQCyc            => MasterQCyc,
      MasterQAddr           => MasterQAddr,
      MasterQDataToSlave    => MasterQDataToSlave,
      MasterQAck            => MasterQAck,
      MasterQErr            => MasterQErr,
      MasterQRty            => MasterQRty,
      MasterQDataFrSlave    => MasterQDataFrSlave,
      StatusRegA            => StatusRegA,
      StatusRegB            => StatusRegB,
      StatusRegC            => StatusRegC,
      SettingRegX           => SettingRegX,
      SettingRstX           => SettingRstX,
      SettingRegY           => SettingRegY,
      SettingRstY           => SettingRstY,
      SettingRegZ           => SettingRegZ,
      SettingRstZ           => SettingRstZ,
      TriggerRegR           => TriggerRegR,
      TriggerClrR           => TriggerClrR,
      TriggerRegS           => TriggerRegS,
      TriggerClrS           => TriggerClrS,
      TriggerRegT           => TriggerRegT,
      TriggerClrT           => TriggerClrT,
      rstZ                  => rstZ);

  procClk: process
  begin
    if WishBoneClock='1' then
      WishBoneClock <= '0';
    else
      WishBoneClock <= '1';
    end if;
    wait for clkPeriod/2;
  end process procClk;

  procRstZ: process
  begin
    rstZ  <= '0';
    wait for 10 ns;
    rstZ  <= '1';
    wait;
  end process procRstZ;

  procWbMasterP: process
  begin
    MasterPStrobe <= '0';
    MasterPWrEn   <= '0';
    MasterPCyc    <= '0';
    MasterPAddr   <= x"0";
    MasterPDataToSlave <= x"00";
    wait for clkPeriod / 10;
    wait for clkPeriod * 5;
    MasterPStrobe <= '1';
    MasterPWrEn   <= '1';
    MasterPCyc    <= '1';
    MasterPAddr   <= x"6";
    MasterPDataToSlave <= x"55";
    wait for clkPeriod * 2;
    MasterPStrobe <= '0';
    MasterPWrEn   <= '0';
    MasterPCyc    <= '0';
    MasterPAddr   <= x"0";
    MasterPDataToSlave <= x"00";
    wait for clkPeriod * 10;
    MasterPStrobe <= '1';
    MasterPWrEn   <= '1';
    MasterPCyc    <= '1';
    MasterPAddr   <= x"6";
    MasterPDataToSlave <= x"99";
    wait for clkPeriod * 2;
    MasterPStrobe <= '0';
    MasterPWrEn   <= '0';
    MasterPCyc    <= '0';
    MasterPAddr   <= x"0";
    MasterPDataToSlave <= x"00";
    wait;
  end process procWbMasterP;
  procWbMasterQ: process
  begin
    MasterQStrobe <= '0';
    MasterQWrEn   <= '0';
    MasterQCyc    <= '0';
    MasterQAddr   <= x"0";
    MasterQDataToSlave <= x"00";
    wait for clkPeriod / 10;
    wait for clkPeriod * 8;
    MasterQStrobe <= '1';
    MasterQWrEn   <= '1';
    MasterQCyc    <= '1';
    MasterQAddr   <= x"6";
    MasterQDataToSlave <= x"77";
    wait for clkPeriod * 2;
    MasterQStrobe <= '0';
    MasterQWrEn   <= '0';
    MasterQCyc    <= '0';
    MasterQAddr   <= x"0";
    MasterQDataToSlave <= x"00";
    wait;
  end process procWbMasterQ;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_wrimm_top of wrimm_top_tb is
  for TB_ARCHITECTURE
    for UUT : wrimm_top
      use entity work.wrimm_top(structure);
    end for;
  end for;
end TESTBENCH_FOR_wrimm_top;

