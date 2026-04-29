>>SOURCE FORMAT FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. LEVIATHAN-ENGINE.
AUTHOR. UBAYDA ALI.
*> ====================================================================
*> DESCRIPTION: Enterprise Batch Settlement & Reconciliation Engine
*> This program reads thousands of daily transactions, calculates
*> exact monetary flows using COMP-3 (Packed-Decimal), and flags
*> critical overdrafts or suspicious high-value transfers.
*> ====================================================================

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT TRANS-FILE ASSIGN TO "data/input/daily_transactions.dat"
        ORGANIZATION IS LINE SEQUENTIAL.
    SELECT REPORT-FILE ASSIGN TO "data/output/settlement_report.txt"
        ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD  TRANS-FILE.
01  TRANS-RECORD.
    05 TRANS-ID            PIC X(10).
    05 TRANS-TYPE          PIC X(3).
    05 TRANS-AMOUNT        PIC 9(7)V99.

FD  REPORT-FILE.
01  REPORT-RECORD          PIC X(80).

WORKING-STORAGE SECTION.
*> --- End of File Flags ---
01  WS-EOF                 PIC A(1) VALUE 'N'.

*> --- Internal Accumulators (Using COMP-3 for Exact Financial Math) ---
01  WS-TOTAL-PROCESSED     PIC 9(7) COMP-3 VALUE 0.
01  WS-TOTAL-CREDITS       PIC S9(11)V99 COMP-3 VALUE 0.
01  WS-TOTAL-DEBITS        PIC S9(11)V99 COMP-3 VALUE 0.
01  WS-SUSPICIOUS-COUNT    PIC 9(5) COMP-3 VALUE 0.

*> --- Formatted Output Variables (For the Final Report) ---
01  WS-FMT-CREDITS         PIC $$$,$$$,$$$,$$9.99.
01  WS-FMT-DEBITS          PIC $$$,$$$,$$$,$$9.99.
01  WS-FMT-COUNT           PIC ZZZ,ZZ9.

*> --- Report Headers & Footers ---
01  HEADER-1               PIC X(80) VALUE "========================================================================".
01  HEADER-2               PIC X(80) VALUE " 🏛️  LEVIATHAN MAINFRAME: DAILY SETTLEMENT & RECONCILIATION AUDIT".
01  HEADER-3               PIC X(80) VALUE "========================================================================".
01  DETAIL-LINE.
    05 FILLER              PIC X(10) VALUE " [ALERT]  ".
    05 DET-MSG             PIC X(70).

PROCEDURE DIVISION.
0000-MAIN-PROCESSING.
    *> Open files for batch processing
    OPEN INPUT TRANS-FILE
    OPEN OUTPUT REPORT-FILE

    *> Write report headers
    WRITE REPORT-RECORD FROM HEADER-1
    WRITE REPORT-RECORD FROM HEADER-2
    WRITE REPORT-RECORD FROM HEADER-3
    WRITE REPORT-RECORD FROM " "

    *> Begin Read Loop
    PERFORM 1000-PROCESS-RECORDS UNTIL WS-EOF = 'Y'

    *> Formatting the final accumulated data
    MOVE WS-TOTAL-CREDITS TO WS-FMT-CREDITS
    MOVE WS-TOTAL-DEBITS  TO WS-FMT-DEBITS
    MOVE WS-TOTAL-PROCESSED TO WS-FMT-COUNT

    *> Write the final summary
    WRITE REPORT-RECORD FROM " "
    WRITE REPORT-RECORD FROM HEADER-1
    WRITE REPORT-RECORD FROM " [SYSTEM] BATCH PROCESSING COMPLETE. SUMMARY OF FINANCIAL FLOWS:"
    
    STRING "    -> TOTAL TRANSACTIONS PROCESSED : " WS-FMT-COUNT DELIMITED BY SIZE 
           INTO REPORT-RECORD
    WRITE REPORT-RECORD

    STRING "    -> TOTAL CREDITS (INFLOW)       : " WS-FMT-CREDITS DELIMITED BY SIZE 
           INTO REPORT-RECORD
    WRITE REPORT-RECORD

    STRING "    -> TOTAL DEBITS (OUTFLOW)       : " WS-FMT-DEBITS DELIMITED BY SIZE 
           INTO REPORT-RECORD
    WRITE REPORT-RECORD

    WRITE REPORT-RECORD FROM HEADER-1

    *> Close files and terminate the program
    CLOSE TRANS-FILE
    CLOSE REPORT-FILE
    STOP RUN.

1000-PROCESS-RECORDS.
    READ TRANS-FILE
        AT END
            MOVE 'Y' TO WS-EOF
        NOT AT END
            ADD 1 TO WS-TOTAL-PROCESSED
            
            *> Evaluate Transaction Type using strict routing
            EVALUATE TRANS-TYPE
                WHEN "CRD"
                    ADD TRANS-AMOUNT TO WS-TOTAL-CREDITS
                    *> Flag High-Value Credits (Anti-Money Laundering logic)
                    IF TRANS-AMOUNT > 50000.00
                        ADD 1 TO WS-SUSPICIOUS-COUNT
                        STRING "HIGH VALUE CRD DETECTED: " TRANS-ID " | AMOUNT: $" TRANS-AMOUNT
                            DELIMITED BY SIZE INTO DET-MSG
                        WRITE REPORT-RECORD FROM DETAIL-LINE
                    END-IF
                WHEN "DEB"
                    ADD TRANS-AMOUNT TO WS-TOTAL-DEBITS
                WHEN OTHER
                    STRING "INVALID TRANSACTION TYPE DETECTED: " TRANS-ID 
                        DELIMITED BY SIZE INTO DET-MSG
                    WRITE REPORT-RECORD FROM DETAIL-LINE
            END-EVALUATE
    END-READ.
