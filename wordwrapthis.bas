DECLARE SUB WordWrapThis (text$, maxwidth%, tempfile$)
OPTION BASE 1
CLS
a$ = a$ + "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed"
a$ = a$ + "do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
a$ = a$ + "Ut enim ad minim veniam, quis nostrud exercitation ullamco "
a$ = a$ + "laboris nisi ut aliquip ex ea commodo consequat. Duis aute "
a$ = a$ + "irure dolor in reprehenderit in voluptate velit esse cillum "
a$ = a$ + "dolore eu fugiat nulla pariatur. Excepteur sint occaecat "
a$ = a$ + "cupidatat non proident, sunt in culpa qui officia deserunt "
a$ = a$ + "mollit anim id est laborum."
a$ = a$ + " " + a$ + " " + a$

REM a$ = "this is a test"
CALL WordWrapThis(a$, 75, "tmp.txt")
OPEN "tmp.txt" FOR INPUT AS #1
    WHILE NOT EOF(1)
        LINE INPUT #1, a$
        PRINT a$
    WEND
    CLOSE #1
KILL "tmp.txt"

SUB WordWrapThis (text$, maxwidth%, tempfile$)
REM **********************************************
REM Takes a string, wraps it to a given length,
REM and sends the result to a temporary text file.
REM Temporary file is DOS-Formatted, with CRLF.
REM **********************************************
    progress% = maxwidth%
    wrappoint% = 1
    break% = 1
    filenum% = FREEFILE
    REM Using assumption of 3-letter average size per word.
    REM even Hemingway should fit into that!
    DIM breakpoints(INT(LEN(text$) / 4)) AS INTEGER
    OPEN tempfile$ FOR OUTPUT AS #filenum%
    IF LEN(text$) <= maxwidth% THEN
        PRINT #filenum%, text$
    ELSE
        REM find out where the spaces are
        FOR f = 1 TO LEN(text$) - 1 '-1 prevents a doubling of the last two codes
            IF MID$(text$, f, 1) = " " THEN
                breakpoints(break%) = f: break% = break% + 1
            END IF
            breakpoints(break%) = LEN(text$)
        NEXT f
        REM now wrap it
        FOR f = 1 TO LEN(text$)
            a$ = MID$(text$, f, 1)
            SELECT CASE a$
                CASE " "
                    IF breakpoints(wrappoint% + 1) <= progress% THEN
                        PRINT #filenum%, " ";
                    ELSE
                        REM remove chr$13 for linux use
                        PRINT #filenum%, CHR$(13) + CHR$(10);
                    END IF
                    IF breakpoints(wrappoint% + 1) > progress% THEN progress% = breakpoints(wrappoint%) + maxwidth%
                    wrappoint% = wrappoint% + 1
                CASE ELSE
                    PRINT #filenum%, a$;
            END SELECT
        NEXT f
        CLOSE #filenum%
    END IF
END SUB

