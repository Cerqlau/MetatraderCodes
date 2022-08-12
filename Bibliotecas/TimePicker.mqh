//+------------------------------------------------------------------+
//|                                                   TimePicker.mqh |
//|                                   Copyright 2019, Julio Monteiro |
//|                     https://www.mql5.com/en/users/havok2k/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Julio Monteiro"
#property link      "https://www.mql5.com/en/users/havok2k/seller"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTimePicker
{
   enum TIME
   {
      T_DISABLED = -1, // -
      T_00_00,         // 00:00
      T_00_05,         // 00:05
      T_00_10,         // 00:10
      T_00_15,         // 00:15
      T_00_20,         // 00:20
      T_00_25,         // 00:25
      T_00_30,         // 00:30
      T_00_35,         // 00:35
      T_00_40,         // 00:40
      T_00_45,         // 00:45
      T_00_50,         // 00:50
      T_00_55,         // 00:55
      T_01_00,         // 01:00
      T_01_05,         // 01:05
      T_01_10,         // 01:10
      T_01_15,         // 01:15
      T_01_20,         // 01:20
      T_01_25,         // 01:25
      T_01_30,         // 01:30
      T_01_35,         // 01:35
      T_01_40,         // 01:40
      T_01_45,         // 01:45
      T_01_50,         // 01:50
      T_01_55,         // 01:55
      T_02_00,         // 02:00
      T_02_05,         // 02:05
      T_02_10,         // 02:10
      T_02_15,         // 02:15
      T_02_20,         // 02:20
      T_02_25,         // 02:25
      T_02_30,         // 02:30
      T_02_35,         // 02:35
      T_02_40,         // 02:40
      T_02_45,         // 02:45
      T_02_50,         // 02:50
      T_02_55,         // 02:55
      T_03_00,         // 03:00
      T_03_05,         // 03:05
      T_03_10,         // 03:10
      T_03_15,         // 03:15
      T_03_20,         // 03:20
      T_03_25,         // 03:25
      T_03_30,         // 03:30
      T_03_35,         // 03:35
      T_03_40,         // 03:40
      T_03_45,         // 03:45
      T_03_50,         // 03:50
      T_03_55,         // 03:55
      T_04_00,         // 04:00
      T_04_05,         // 04:05
      T_04_10,         // 04:10
      T_04_15,         // 04:15
      T_04_20,         // 04:20
      T_04_25,         // 04:25
      T_04_30,         // 04:30
      T_04_35,         // 04:35
      T_04_40,         // 04:40
      T_04_45,         // 04:45
      T_04_50,         // 04:50
      T_04_55,         // 04:55
      T_05_00,         // 05:00
      T_05_05,         // 05:05
      T_05_10,         // 05:10
      T_05_15,         // 05:15
      T_05_20,         // 05:20
      T_05_25,         // 05:25
      T_05_30,         // 05:30
      T_05_35,         // 05:35
      T_05_40,         // 05:40
      T_05_45,         // 05:45
      T_05_50,         // 05:50
      T_05_55,         // 05:55
      T_06_00,         // 06:00
      T_06_05,         // 06:05
      T_06_10,         // 06:10
      T_06_15,         // 06:15
      T_06_20,         // 06:20
      T_06_25,         // 06:25
      T_06_30,         // 06:30
      T_06_35,         // 06:35
      T_06_40,         // 06:40
      T_06_45,         // 06:45
      T_06_50,         // 06:50
      T_06_55,         // 06:55
      T_07_00,         // 07:00
      T_07_05,         // 07:05
      T_07_10,         // 07:10
      T_07_15,         // 07:15
      T_07_20,         // 07:20
      T_07_25,         // 07:25
      T_07_30,         // 07:30
      T_07_35,         // 07:35
      T_07_40,         // 07:40
      T_07_45,         // 07:45
      T_07_50,         // 07:50
      T_07_55,         // 07:55
      T_08_00,         // 08:00
      T_08_05,         // 08:05
      T_08_10,         // 08:10
      T_08_15,         // 08:15
      T_08_20,         // 08:20
      T_08_25,         // 08:25
      T_08_30,         // 08:30
      T_08_35,         // 08:35
      T_08_40,         // 08:40
      T_08_45,         // 08:45
      T_08_50,         // 08:50
      T_08_55,         // 08:55
      T_09_00,         // 09:00
      T_09_05,         // 09:05
      T_09_10,         // 09:10
      T_09_15,         // 09:15
      T_09_20,         // 09:20
      T_09_25,         // 09:25
      T_09_30,         // 09:30
      T_09_35,         // 09:35
      T_09_40,         // 09:40
      T_09_45,         // 09:45
      T_09_50,         // 09:50
      T_09_55,         // 09:55
      T_10_00,         // 10:00
      T_10_05,         // 10:05
      T_10_10,         // 10:10
      T_10_15,         // 10:15
      T_10_20,         // 10:20
      T_10_25,         // 10:25
      T_10_30,         // 10:30
      T_10_35,         // 10:35
      T_10_40,         // 10:40
      T_10_45,         // 10:45
      T_10_50,         // 10:50
      T_10_55,         // 10:55
      T_11_00,         // 11:00
      T_11_05,         // 11:05
      T_11_10,         // 11:10
      T_11_15,         // 11:15
      T_11_20,         // 11:20
      T_11_25,         // 11:25
      T_11_30,         // 11:30
      T_11_35,         // 11:35
      T_11_40,         // 11:40
      T_11_45,         // 11:45
      T_11_50,         // 11:50
      T_11_55,         // 11:55
      T_12_00,         // 12:00
      T_12_05,         // 12:05
      T_12_10,         // 12:10
      T_12_15,         // 12:15
      T_12_20,         // 12:20
      T_12_25,         // 12:25
      T_12_30,         // 12:30
      T_12_35,         // 12:35
      T_12_40,         // 12:40
      T_12_45,         // 12:45
      T_12_50,         // 12:50
      T_12_55,         // 12:55
      T_13_00,         // 13:00
      T_13_05,         // 13:05
      T_13_10,         // 13:10
      T_13_15,         // 13:15
      T_13_20,         // 13:20
      T_13_25,         // 13:25
      T_13_30,         // 13:30
      T_13_35,         // 13:35
      T_13_40,         // 13:40
      T_13_45,         // 13:45
      T_13_50,         // 13:50
      T_13_55,         // 13:55
      T_14_00,         // 14:00
      T_14_05,         // 14:05
      T_14_10,         // 14:10
      T_14_15,         // 14:15
      T_14_20,         // 14:20
      T_14_25,         // 14:25
      T_14_30,         // 14:30
      T_14_35,         // 14:35
      T_14_40,         // 14:40
      T_14_45,         // 14:45
      T_14_50,         // 14:50
      T_14_55,         // 14:55
      T_15_00,         // 15:00
      T_15_05,         // 15:05
      T_15_10,         // 15:10
      T_15_15,         // 15:15
      T_15_20,         // 15:20
      T_15_25,         // 15:25
      T_15_30,         // 15:30
      T_15_35,         // 15:35
      T_15_40,         // 15:40
      T_15_45,         // 15:45
      T_15_50,         // 15:50
      T_15_55,         // 15:55
      T_16_00,         // 16:00
      T_16_05,         // 16:05
      T_16_10,         // 16:10
      T_16_15,         // 16:15
      T_16_20,         // 16:20
      T_16_25,         // 16:25
      T_16_30,         // 16:30
      T_16_35,         // 16:35
      T_16_40,         // 16:40
      T_16_45,         // 16:45
      T_16_50,         // 16:50
      T_16_55,         // 16:55
      T_17_00,         // 17:00
      T_17_05,         // 17:05
      T_17_10,         // 17:10
      T_17_15,         // 17:15
      T_17_20,         // 17:20
      T_17_25,         // 17:25
      T_17_30,         // 17:30
      T_17_35,         // 17:35
      T_17_40,         // 17:40
      T_17_45,         // 17:45
      T_17_50,         // 17:50
      T_17_55,         // 17:55
      T_18_00,         // 18:00
      T_18_05,         // 18:05
      T_18_10,         // 18:10
      T_18_15,         // 18:15
      T_18_20,         // 18:20
      T_18_25,         // 18:25
      T_18_30,         // 18:30
      T_18_35,         // 18:35
      T_18_40,         // 18:40
      T_18_45,         // 18:45
      T_18_50,         // 18:50
      T_18_55,         // 18:55
      T_19_00,         // 19:00
      T_19_05,         // 19:05
      T_19_10,         // 19:10
      T_19_15,         // 19:15
      T_19_20,         // 19:20
      T_19_25,         // 19:25
      T_19_30,         // 19:30
      T_19_35,         // 19:35
      T_19_40,         // 19:40
      T_19_45,         // 19:45
      T_19_50,         // 19:50
      T_19_55,         // 19:55
      T_20_00,         // 20:00
      T_20_05,         // 20:05
      T_20_10,         // 20:10
      T_20_15,         // 20:15
      T_20_20,         // 20:20
      T_20_25,         // 20:25
      T_20_30,         // 20:30
      T_20_35,         // 20:35
      T_20_40,         // 20:40
      T_20_45,         // 20:45
      T_20_50,         // 20:50
      T_20_55,         // 20:55
      T_21_00,         // 21:00
      T_21_05,         // 21:05
      T_21_10,         // 21:10
      T_21_15,         // 21:15
      T_21_20,         // 21:20
      T_21_25,         // 21:25
      T_21_30,         // 21:30
      T_21_35,         // 21:35
      T_21_40,         // 21:40
      T_21_45,         // 21:45
      T_21_50,         // 21:50
      T_21_55,         // 21:55
      T_22_00,         // 22:00
      T_22_05,         // 22:05
      T_22_10,         // 22:10
      T_22_15,         // 22:15
      T_22_20,         // 22:20
      T_22_25,         // 22:25
      T_22_30,         // 22:30
      T_22_35,         // 22:35
      T_22_40,         // 22:40
      T_22_45,         // 22:45
      T_22_50,         // 22:50
      T_22_55,         // 22:55
      T_23_00,         // 23:00
      T_23_05,         // 23:05
      T_23_10,         // 23:10
      T_23_15,         // 23:15
      T_23_20,         // 23:20
      T_23_25,         // 23:25
      T_23_30,         // 23:30
      T_23_35,         // 23:35
      T_23_40,         // 23:40
      T_23_45,         // 23:45
      T_23_50,         // 23:50
      T_23_55,         // 23:55
      T_24_00,         // 24:00
   };

   public:
      datetime ReplaceTime(datetime date, TIME time)
      {
         return time == T_DISABLED ? T_DISABLED : (date - date % 86400) + 5 * 60 * time;
      }
};
