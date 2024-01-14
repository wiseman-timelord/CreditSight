# CreditSight-Ps

### STATUS: ALPHA
Work to do...
- Finish updates to "Create-PredictionGraph"
- Progress scripts to completion over initial plans, think into these plans along the way.
- have option for toggle, bi-directional or 2 graphs (history, prediction). 

### DESCRIPTION
CreditSight is a PowerShell-based personal finance tracking application designed to provide users with a comprehensive view of their financial status. It focuses on visualizing financial data through graphs and maintaining detailed records of financial changes over time.

### FEATURES
- **Credit Visualization**: Visualizes financial changes using a line graph, where each character on the graph represents a scaled period of financial change, combining both history and prediction.
- **Intelligent ASCII Graphs**: Utilizes different characters to represent various financial states - £ for credit, * for higher credit values, x for debt, and X for significant debt.
- **Volatility Prediction**: Displays prediction uncertainty through the thickness of the band in the prediction graph, indicating the volatility of future financial trends.
- **Daily Record Rotation**: Features a rotating record system where `DayRecords_10` updates every 10 days and `DayRecords_100` every 100 days, enabling three years of predictive capability and historical record-keeping.

### PREVIEW
ARRrrhhh, das nicht compute..
```
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
Attempting to load configuration from: scripts/configuration.psd1
Configuration file found.
Configuration loaded successfully.
Current Total: 0.00
Last Finance Change:
Day Credit Low: 0
Day Credit High: 0
Day Credit Now: 0
Monthly Expenses: 0

Select, Credit Change=C, Monthly Charge=M, Exit Program=X:
```

## DISCLAIMER
This software is subject to the terms in License.Txt, covering usage, distribution, and modifications. For full details on your rights and obligations, refer to License.Txt.
