VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisWorkbook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Sub stockAnalysis():
    
    Dim total As LongLong ' total stock volume
    Dim row As Long ' loop control variable that will go through the rows of the sheet
    Dim rowCount As Long ' variable will hold the number of rows in a sheet
    Dim yearlychange As Double ' vairable that hold the yearly change for each stock in a sheet
    Dim percentChange As Double ' variable that hold the percent change for each stock in a sheet
    Dim summaryTableRow As Long ' variable hold the rows of the summary
    Dim stockStartRow As Long ' variable that holds the start of a stock's rows in a sheet
           
    ' loop through all of the worksheets
    For Each ws In Worksheets
    
        ' set the title row
        ws.Range("I1").Value = "Ticker"
        ws.Range("J1").Value = "Yearly Change"
        ws.Range("K1").Value = "Percent Change"
        ws.Range("L1").Value = "Total"
        ws.Range("P1").Value = "Ticker"
        ws.Range("Q1").Value = "Value"
        ws.Range("O2").Value = "Greatest % Increase"
        ws.Range("O3").Value = "Greatest % Decrease"
        ws.Range("O4").Value = "Greatest Total Volume"
        
        ' initialize the values
        summaryTableRow = 0 ' summary table row starts at 0 in the sheet
        total = 0 ' total stock volume for a stock starts at 0
        yearlychange = 0 ' yearly change starts at 0
        stockStartRow = 2 ' first stock in the sheet is going to be on row 2
        
        ' get the value of the last row in the sheet
        rowCount = ws.Cells(Rows.Count, "A").End(-4162).row
        
        ' loop until we get to the end of the sheet
        For row = 2 To rowCount
            
            ' check to see if there are changes in column A (for column 1)
            If ws.Cells(row + 1, 1).Value <> ws.Cells(row, 1).Value Then
            
                ' calculate the total one last time for the ticker
                total = total + ws.Cells(row, 7).Value ' Grabs the value from the 7th column (G)
                
                ' check to see if the value of the total volume is 0
                If total = 0 Then
                    ' print those results (Columns I, J, K, and L)
                    ws.Range("I" & 2 + summaryTableRow).Value = ws.Cells(row, 1).Value ' prints the stock name in Column I
                    ws.Range("J" & 2 + summaryTableRow).Value = 0 ' prints the 0 in Column J (yearly change)
                    ws.Range("K" & 2 + summaryTableRow).Value = 0 & "%" ' prints the 0% in Column K (% change)
                    ws.Range("L" & 2 + summaryTableRow).Value = 0 ' prints 0 name in Column L (total stock volume)
                Else
                    ' find the first non-zero starting value
                    If ws.Cells(stockStartRow, 3).Value = 0 Then
                        For findValue = stockStartRow To row
                            ' check to see if the (or next) value does not equal 0
                            If ws.Cells(findValue, 3).Value <> 0 Then
                                stockStartRow = findValue
                                ' once we have a non-zero value, break out of the loop
                                Exit For
                            End If
                        Next findValue
                    End If
                    
                    ' calculate the yearly change (difference in lst close - first open)
                    yearlychange = (ws.Cells(row, 6).Value - ws.Cells(stockStartRow, 3).Value)
                    ' calculate the percent change (yearly change /first open)
                    percentChange = yearlychange / ws.Cells(stockStartRow, 3).Value
                                   
                    ' print those results (Columns I, J, K, and L)
                    ws.Range("I" & 2 + summaryTableRow).Value = ws.Cells(row, 1).Value ' prints the stock name in Column I
                    ws.Range("J" & 2 + summaryTableRow).Value = yearlychange ' prints the 0 in Column J (yearly change)
                    ws.Range("J" & 2 + summaryTableRow).NumberFormat = "0.00" ' format column J
                    ws.Range("K" & 2 + summaryTableRow).Value = percentChange ' prints in Column K (% change)
                    ws.Range("K" & 2 + summaryTableRow).NumberFormat = "0.00%" ' format column K
                    ws.Range("L" & 2 + summaryTableRow).Value = total ' prints in Column L (total stock volume)
                    ws.Range("L" & 2 + summaryTableRow).NumberFormat = "#,###" ' format column K
                    
                    ' formatting for the yearlyChange column
                    If yearlychange > 0 Then
                        ws.Range("J" & 2 + summaryTableRow).Interior.ColorIndex = 4 ' green = +
                    ElseIf yearlychange < 0 Then
                        ws.Range("J" & 2 + summaryTableRow).Interior.ColorIndex = 3 ' red = -
                    Else
                        ws.Range("J" & 2 + summaryTableRow).Interior.ColorIndex = 0 ' white/no change = 0
                    End If
                    
                End If
                
                ' reset the values of the total
                total = 0
                ' reset the value of the yearly change
                yearlychange = 0
                ' move to the next row in the summary table
                summaryTableRow = summaryTableRow + 1
                
            ' if the ticker is the same
            Else
                total = total + ws.Cells(row, 7).Value ' Grabs the value from the 7th column (G)
                        
            End If
                
        Next row
        
        ' after looping through the rows, find max and min and place them in Q2, Q3, and Q4
        ws.Range("Q2").Value = "%" & WorksheetFunction.Max(ws.Range("K2:K" & rowCount)) * 100 ' value for greatest increase
        ws.Range("Q3").Value = "%" & WorksheetFunction.Min(ws.Range("K2:K" & rowCount)) * 100 ' value for greatest decrease
        ws.Range("Q4").Value = "%" & WorksheetFunction.Max(ws.Range("L2:L" & rowCount)) * 100 ' value of the greatest max volume
        ws.Range("Q4").NumberFormat = "#,###" ' formats the greatest max volume
        
        ' do matching in order to match the ticker names to the values
        ' tells the row in the summary table where the ticker mathces the greatest increase
        increaseNumber = WorksheetFunction.Match(WorksheetFunction.Max(ws.Range("K2:K" & rowCount)), ws.Range("K2:K" & rowCount), 0)
        ws.Range("P2").Value = ws.Cells(increaseNumber + 1, 9)
        
        ' tells the row in the summary table where the ticker mathces the greatest decrease
        decreaseNumber = WorksheetFunction.Match(WorksheetFunction.Min(ws.Range("K2:K" & rowCount)), ws.Range("K2:K" & rowCount), 0)
        ws.Range("P3").Value = ws.Cells(decreaseNumber + 1, 9)
        
        ' tells the row in the summary table where the ticker mathces the greatest total volume
        volNumber = WorksheetFunction.Match(WorksheetFunction.Min(ws.Range("L2:L" & rowCount)), ws.Range("L2:L" & rowCount), 0)
        ws.Range("P4").Value = ws.Cells(volNumber + 1, 9)
                 
        ' AutoFit the columns
        ws.Columns("A:Q").AutoFit
        
    Next ws
    
    
End Sub

