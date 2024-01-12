# CreditSight-Ps

### STATUS: ALPHA
- Finanace planner details still to be finalized, prediction and history, ascii line graphs and numbers.

### FEATURES
- ** Credit Visualization ** On the History line graph each character represents a day's financial change, the graph will be constructed as an array of strings, where each string is a line in the graph. The thickness of the band in the prediction graph will represent the uncertainty or volatility in the prediction. A wider band indicates greater uncertainty.
- ** Daily Rotation ** Upon events of, booting and next day, the graph will be kept current, the keys will be checked against the system date/time hourly.

### NOTES
- The average number of days in a year, accounting for leap years, is 365.25. The average number of days in a month, accounting for leap years, is approximately 30.4375. Thats 1/8 or 3 hours, 1 for each 2 main solstice days. Unfortunately such logic is not applicable to the program, as the user would eventually go noticbly out of synchronicity with the systems that use Gregorgian calendar.
