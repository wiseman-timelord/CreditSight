# CreditSight-Ps

### STATUS: ALPHA
Work to do...
- Progress scripts to completion over initial plans, think into these plans along the way
- Implement upcoming charges, to enter up to 3 known upcoming charges to your finances, or maybe it would be based upon weeks instead of days, or, lists of following, 7 day and 4 week and 3 month, periods etc, and it would not affect the prediction too bad, and still be accurate enough? there are ideas for re-occuring charges too. 

### DESCRIPTION
- Finanace planner details still to be finalized, prediction and history, ascii line graphs and numbers. 

### FEATURES
- ** Credit Visualization ** On the History line graph each character represents a day's financial change, the graph will be constructed as an array of strings, where each string is a line in the graph. £ for credit, * for top 50% credit, x for debt, X for top 50% debt.
- ** Volatility Prediction ** The thickness of the band in the prediction graph will represent the uncertainty or volatility in the prediction. 
- ** Daily Rotation ** Records_10 should rotate every 10 days, and DayRecords_100 every 100 days. PowerShell's array slicing can be utilized to shift elements in the array efficiently.
