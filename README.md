# CreditSight-Ps

### STATUS: ALPHA
Work to do...
- Fix graph generation. Wooo... "https://geekeefy.wordpress.com/2017/09/04/plot-graph-in-powershell-console/"
- Improve layout of graphs.
- try put borders on graphs.
- The line "$global:filePath = 'scripts/settings.psd1'" allows one to specify the config file, hence, we could have a menu as first screen, to, create new or select existing, settings file, so as to have profiles (.\profiles\ExampleProfileName.Psd1), ie, personal, trading, business, etc, with differing, history and credit. 
- Improve layout of new profile menu.
- Progress scripts to completion over initial plans, think into these plans along the way.
- have option for toggle, bi-directional or 2 graphs (history, prediction). 

## DESCRIPTION
CreditSight is a PowerShell-based personal finance tracking application designed to provide users with a comprehensive view of their financial status. It focuses on visualizing financial data through graphs and maintaining detailed records of financial changes over time.

### FEATURES
- **Credit Visualization**: Visualizes financial changes using a line graph, where each character on the graph represents a scaled period of financial change, combining both history and prediction, based on daily recording of credit.
- **Intelligent ASCII Graphs**: Utilizes different characters to represent various financial states - £ for credit, * for higher credit values, x for debt, and X for significant debt.
- **Volatility Prediction**: Displays prediction uncertainty through the thickness of the band in the prediction graph, indicating the volatility of future financial trends, based on, current and past, high/low.
- **Daily Record Rotation**: Features a rotating record system where `DayRecords_10` updates every 10 days and `DayRecords_100` every 100 days, enabling three tiers of predictive capability and historical record-keeping, totalling, 1110 days or 3 years, of history/prediction.

### PREVIEW
This is the best I could do without involving modules...we will now be involving modules..
```
CreditSight Started....


          X
         X
        X
       X
      X
    X
   X
  X
 X
X
    X
    X
    X
    X
    X
   X
   X
   X
   X
   X
   X
   X
   X
   X
   X
   X
   X
   X
   X
   X

              Current Credit: 0.00, Last Change: 0.00,

                      Monthly Expenses: 0.00,

              Current High: 0.00, Highest High: 0.00,
               Current Low: 0.00, Lowest Low: 0.00.


Select, Credit Change = C, Set Monthly = M, Exit Program = X:
```

### NOTATION
- Issues with GPT code windows during production of "graph.ps1", the most difficult script to produce in the project.

### DEVELOPMENT
REFRESH:
The 2 graphs, history and prediction, will be based around, a string and a band, where the band would be central to the graph in height when the balance is 0, and...
-the entry point is "Display-Graph".
-the height of each graph should be 15 lines.
-if the band was in the middle 50% of the graph, this would be yellow blocks, representing low credit/debt.
-if the band was in high credit, then they would in the top 25% of the graph in green.
-if the band was in high debt, then they would be in the bottom 25% of the graph in red.
- height in the graph represents credit level, this should be scaled to the, highest high and lowest low.
-we will simplify things width on the graph should represent as are applicable, the 30 values for recorded history or the 30 predicted values based on the 30 recorded history; for each of the 10x10days we will divide the number by 10 for the graph and for each of the 10x100days we will divide the number by 100 for the graph, so as, to not need to scale the width, and use average days for those representations. thus the graph will always be 30 width. 
- for the history graph, thickness of the band should only be a single character string, using purely the values of, "DayRecords_100" and "DayRecords_10" and "DayRecords_1", produing a 30 character string.
- for the prediction graph it should be a band, where the string for the history is then, inverted and smoothed, while having variance in the band, based upon a middle point between the, current days high + all time high and the current days low + all time low.


## DISCLAIMER
This software is subject to the terms in License.Txt, covering usage, distribution, and modifications. For full details on your rights and obligations, refer to License.Txt.
