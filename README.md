# DS1302 Module
|   Since    | Origin/Contribuitor | Mantainer     | Source     |
|------------|---------------------|---------------|------------|
| 2023-12-30 | Ramón Tavares       | Ramón Tavares | ds1302.lua |

This Lua module provides access to DS1302 ISP real-time clock.

|  Note                                                          |
|----------------------------------------------------------------|
|  This module does not require ISP C module built into firmware |

## Require 

|  ds1302 = require("ds1302")                                   |
|---------------------------------------------------------------|

## Release 

|  ds1302 =  nil
|---------------------------------------------------------------|
|  package.loaded["ds1302"] = nil                               |

|  ds1302.setTime()  |  Sets the current date and time          |
|--------------------|------------------------------------------|
|  ds1302.getTime()  |  Get the current date and time           |

# ds1302.setTime()
Sets the current date and time.

# Syntaxs
ds1302.setTime(second, minute, hour, day, date, month, year)

## Parameters 
* second: 00-59
* minute: 00-59
* hour: 00-23
* day: 1-7 (Sunday = 1, Saturday = 7)
* date: 01-31
* month: 01-12
* year: 00-99

## Returns
nil

## Example 

ds1302 = require("ds1302")

-- Set date and time to Saturday, December 30th 2023 8:29PM
ds1302.setTime(0, 29, 20, 6, 30, 12, 23)

-- Don't forget to release it after use:
ds1302 = nil
package.loaded["ds1302"] = nil


# ds1302.getTime()
Get the current date and time.

# Syntaxs
ds1302.getTime()

## Parameters 
none

## Returns
* second: integer. Second  00-59
* minute: integer. Minute 00-59
* hour: integer. Hour 00-23
* day: integer. Day 1-7 (Sunday = 1, Saturday = 7)
* date: integer. Date 01-31
* month: integer. Month 01-12
* year: integer. Year 00-99

## Example 

ds1302 = require("ds1302")

-- Get date and time t
second, minute, hour, day, date, month, year = ds1302.getTime()

-- Print date and time
print(string.format("Time & Date: %s:%s:%s %s/%s/%s",
      hour, minute, second, date, month, year))

-- Don't forget to release it after use:
ds1302 = nil
package.loaded["ds1302"] = nil

## Operating circuit

.--------------.                   .--------------. 
|   Nodemcu    |                   |    DS1302    |
|           ce |------------------>|CE            |
|         mosi |>------o           |              |
|              |       |           |              |
|              |      .-. R10k     |              |
|              |      | |          |              |
|              |      | |          |              |
|              |       -           |              |
|              |       |           |              |
|         miso |<------o---------->| I/O          |         
|         clk  |>----------------->| SCLK         |       
----------------                   ----------------

    
