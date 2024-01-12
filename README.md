# CreditSight-Ps
Finanace planner details still to be finalized, prediction and history, ascii line graphs and numbers.

Part 1:
By using day records like for example
  1DayRecords = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	10DayRecords = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	100DayRecords = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	1000DayRecodss = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
so we will also need 2 new keys in the "Ps1" and a rename, for "DayCreditLow" and "DaYCreditHigh" and "DayCreditNow".  

Upon booting and events of next day, the graph will be kept current, so it needs to check every hour what the, time and date, are against the and requred todays date,, Loading the and Event Next Day on system Date/Time, the keys on the ,  will be checked against the syand  the "DayCreditNow" will be enalso be linked from 

Display:
The graph will be constructed as an array of strings, where each string is a line in the graph.
Data Representation: Each character on the line graph represents a day's financial change. The graph will be constructed as an array of strings, where each string is a line in the graph.
Band Thickness: The thickness of the band in the prediction graph will represent the uncertainty or volatility in the prediction. A wider band indicates greater uncertainty.
actual variance within the day. 

3 / 3


```
Histoy:
|----------------------------------------------------------------|
|                                                                |
|     *                                                          |
|    £ £           £££ £   £                                     |
| £££   £       £££   £ £££ £                                    |
|£       £     £                                                 |
|         x   x                                                  |
|          X X                                                   |
|           X                                                    |
|                                                                |
|----------------------------------------------------------------|
```
