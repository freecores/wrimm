--Propery of Tecphos Inc.  See License.txt for license details
--Latest version of all project files available at http://opencores.org/project,wrimm
--See WrimmManual.pdf for the Wishbone Datasheet and implementation details.
--See wrimm subversion project for version history

library ieee;
  use ieee.std_logic_1164.all;

package WrimmPackage is

  constant WbAddrBits   : Integer := 4;
  constant WbDataBits   : Integer := 8;

  subtype     WbAddrType  is std_logic_vector(0 to WbAddrBits-1);
  subtype     WbDataType  is std_logic_vector(0 to WbDataBits-1);

  type WbMasterOutType is record
    Strobe        : std_logic;                  --Required
    WrEn          : std_logic;
    Addr          : WbAddrType;
    Data          : WbDataType;
    --DataTag       : std_logic_vector(0 to 1);   --Write,Set,Clear,Toggle
    Cyc           : std_logic;                  --Required
    --CycType       : std_logic_vector(0 to 2);   --For Burst Cycles
  end record WbMasterOutType;

  type WbSlaveOutType is record
    Ack           : std_logic;                  --Required
    Err           : std_logic;
    Rty           : std_logic;
    Data          : WbDataType;
  end record WbSlaveOutType;

--=============================================================================
-------------------------------------------------------------------------------
--  Master Interfaces
-------------------------------------------------------------------------------
  type WbMasterType is (
    Q,
    P);

  type WbMasterOutArray is array (WbMasterType) of WbMasterOutType;
  type WbSlaveOutArray  is array (WbMasterType) of WbSlaveOutType;

  type WbMasterGrantType is Array (WbMasterType'left to WbMasterType'right) of std_logic;
--=============================================================================
-------------------------------------------------------------------------------
--  Status Registers (Report internal results)
-------------------------------------------------------------------------------
  type StatusFieldParams is record
    BitWidth  : integer;
    MSBLoc    : integer;
    Address   : WbAddrType;
  end record StatusFieldParams;

  type StatusFieldType is (
    StatusA,
    StatusB,
    StatusC);

  type StatusArrayType      is Array (StatusFieldType'left to StatusFieldType'right)  of WbDataType;
  type StatusArrayBitType   is Array (StatusFieldType'left to StatusFieldType'right)  of std_logic;
  type StatusFieldDefType   is Array (StatusFieldType'left to StatusFieldType'right)  of StatusFieldParams;

  constant StatusParams : StatusFieldDefType  :=(
    StatusA           => (BitWidth =>  8, MSBLoc =>  0, Address => x"0"),
    StatusB           => (BitWidth =>  8, MSBLoc =>  0, Address => x"1"),
    StatusC           => (BitWidth =>  8, MSBLoc =>  0, Address => x"2"));
--=============================================================================
-------------------------------------------------------------------------------
--  Setting Registers
-------------------------------------------------------------------------------
  type SettingFieldParams is record
    BitWidth  : integer;
    MSBLoc    : integer;
    Address   : WbAddrType;
    Default   : WbDataType;
  end record SettingFieldParams;

  type SettingFieldType     is (
    SettingX,
    SettingY,
    SettingZ);

  type SettingArrayType     is Array (SettingFieldType'Left to SettingFieldType'Right)  of WbDataType;
  type SettingArrayBitType  is Array (SettingFieldType'Left to SettingFieldType'Right)  of std_logic;
  type SettingFieldDefType  is Array (SettingFieldType'Left to SettingFieldType'Right)  of SettingFieldParams;

  constant SettingParams : SettingFieldDefType  :=(
    SettingX    => (BitWidth => 8, MSBLoc =>  0, Address => x"6", Default => x"00"),
    SettingY    => (BitWidth => 8, MSBLoc =>  0, Address => x"7", Default => x"00"),
    SettingZ    => (BitWidth => 8, MSBLoc =>  0, Address => x"8", Default => x"00"));
--=============================================================================
-------------------------------------------------------------------------------
--  Trigger Registers (Report internal results)
-------------------------------------------------------------------------------
  type TriggerFieldParams is record
    BitLoc    : integer;
    Address   : WbAddrType;
  end record TriggerFieldParams;

  type TriggerFieldType  is (
    TriggerR,
    TriggerS,
    TriggerT);

  type TriggerArrayType     is Array (TriggerFieldType'Left to TriggerFieldType'Right)  of std_logic;
  type TriggerFieldDefType  is Array (TriggerFieldType'Left to TriggerFieldType'Right)  of TriggerFieldParams;

  constant TriggerParams : TriggerFieldDefType :=(
    TriggerR      => (BitLoc => 7, Address => x"A"),
    TriggerS      => (BitLoc => 7, Address => x"B"),
    TriggerT      => (BitLoc => 7, Address => x"C"));

end package WrimmPackage;

--package body WishBonePackage is
--
--
--
--end package body WishBonePackage;
