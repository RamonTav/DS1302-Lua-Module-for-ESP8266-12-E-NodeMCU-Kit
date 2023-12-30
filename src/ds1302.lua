---------------------------------------------
-- DS1302 SPI moudle for NODEMCU
-- Tavares electronics
-- LICENCE: http://opensource.org/licence/MIT
-- Ramón O. Tavares B. <ramontavbor@gmail.com>
---------------------------------------------

local moduleName = ...
local M = {}
_G[moduleName] = M

-- Set GPIO to SPI
local clk, miso, mosi, ce = 5, 6, 7, 8
gpio.mode(clk,  gpio.OUTPUT) --CLK
gpio.mode(miso, gpio.INPUT)  --MISO
gpio.mode(mosi, gpio.OUTPUT) --MOSI
gpio.mode(ce,   gpio.OUTPUT) --CE 

-- RTC  Register read address
local secondsRead  = 0x81 -- 81h read seconds register
local minutesRead  = 0x83 -- 83h read minutes register
local hourRead     = 0x85 -- 85h read hour    register
local dayRead      = 0x8B -- 8Bh read day     register
local dateRead     = 0x87 -- 87h read date    register
local monthRead    = 0x89 -- 89h read date    register
local yearRead     = 0x8D -- 8Dh read year    register
local RTC_Read     = {secondsRead, minutesRead, hourRead, dayRead, dateRead, monthRead, yearRead}

-- RTC Register write address
local secondsWrite = 0x80 -- 80h write seconds register
local minutesWrite = 0x82 -- 82h write minutes register
local hourWrite    = 0x84 -- 84h write hour    register
local dayWrite     = 0x8A -- 8Ah write day     register
local dateWrite    = 0x86 -- 86h write date    register
local monthWrite   = 0x88 -- 88h write date    register
local yearWrite    = 0x8C -- 8Ch write year    register
local RTC_Write    = {secondsWrite, minutesWrite, hourWrite, dayWrite, dateWrite, monthWrite, yearWrite}

-- Local functions

local function decToBcd(dec)
   if dec == nil then return 0 end
   bcd = ((((dec/10) - ((dec/10)%1)) *16) + (dec%10))
   return bcd
  end

local function bcdToDec(bcd)
  nibbleH = (bcd[5]*1 + bcd[6]*2 + bcd[7]*4 + bcd[8]*8) * 10
  nibbleL = (bcd[1]*1 + bcd[2]*2 + bcd[3]*4 + bcd[4]*8) 
  dec     = nibbleH + nibbleL
  return dec 
end

local function bcdToBin(bcd)
   local binTab = {}
   for i = 8, 1, -1 do
      binTab[i] = bit.band(bcd, 1)
      bcd = bit.rshift(bcd, 1)
   end
   return binTab 
end

local function sendBits(byte)
   local bit
   for i = 8, 1, -1 do
      bit  = byte[i]
      if bit  == 1 then
         gpio.write(mosi, gpio.HIGH)
      else
         gpio.write(mosi, gpio.LOW)
      end
      tmr.delay(10)
      gpio.write(clk, gpio.HIGH)
      tmr.delay(10)
      gpio.write(clk, gpio.LOW)
   end
end

local function sendCommandByte(command)
   gpio.write(ce,  gpio.LOW)
   gpio.write(clk, gpio.LOW)
   tmr.delay(10)
   gpio.write(ce,  gpio.HIGH)
   tmr.delay(10)
   commandBin = bcdToBin(command)
   sendBits(commandBin)
end

local function readRegister() 
   local dataByte = {}
   tmr.delay(10)
   dataByte[1] = gpio.read(miso)
   gpio.write(clk, gpio.HIGH)
   tmr.delay(10)
   for i = 2, 8 do
      gpio.write(clk, gpio.LOW)
      tmr.delay(10)
      dataByte[i] = gpio.read(miso)
      gpio.write(clk, gpio.HIGH)
      tmr.delay(10)
   end
return dataByte
end

-- Module functions

function M.setTime(seconds, minutes, hour, day, date,  month,  year)
   dataArray = {seconds, minutes, hour, day, date,  month,  year}
   for k, v in pairs(RTC_Write) do
      address = v
      data    = dataArray[k]
      sendCommandByte(address)
      datax   = decToBcd(data)
      dataBin = bcdToBin(datax)
      sendBits(dataBin)
   end
end

function M.getTime() 
   local RTC_Registers = {}
   for k, v in pairs(RTC_Read) do
      sendCommandByte(v)
      RTC_Registers[k] = readRegister()
   end 
   RTC_Registers[1][8] = 0 -- Discount bit 7 on seconds data byte
   RTC_Registers[3][8] = 0 -- Discount bit 7 on hour data byte
   RTC_Registers[3][7] = 0 -- Discount bit 6 on hour data byte
   seconds = bcdToDec(RTC_Registers[1])
   minutes = bcdToDec(RTC_Registers[2])
   hour    = bcdToDec(RTC_Registers[3])
   day     = bcdToDec(RTC_Registers[4])
   date    = bcdToDec(RTC_Registers[5])
   month   = bcdToDec(RTC_Registers[6])
   year    = bcdToDec(RTC_Registers[7])
   return year, month, date, day, hour, minutes, seconds
end

return M
