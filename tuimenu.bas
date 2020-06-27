REM TUIMENU
REM (c) Michel Clasquin-Johnson 2020
REM Released into the Public Domain

REM A menuing program for QuickBasic 4.5 in screen mode 0.
REM this demo presents not one, but TWO menuing systems.
REM The first presents the menus in horizontal overlays, with hotkeys.
REM The second uses hotkeys for the firstlevel, but then uses
REM Up, Down, Left, Right, Enter and Esc (or Space) in the way you
REM are probably used to in other programs. They work from the same
REM configuration file, so it is possible to write completely different
REM interfaces for your program that are functionally equivalent.

REM Written in pure BASIC, no weird external assembly routines required.
REM That makes it slower, but every core of my i7 would run rings around
REM a 1990 mainframe so who cares, really?

REM Create a menu of up to five items on the top line of the screen.
REM Each item can be used to trigger an action directly,
REM or it can create a sub-item of another five actions.
REM The menu is not on the screen permanently. When you don't need it,
REM it can get out of your way and give you all of your precious screen
REM to play with. That goes for both of them, but I am illustrating here
REM with fullscreen for the horizontal menu and partial-screen for the
REM dropdown menu

REM The menu can be populated from a file, with a very simple format
REM (good for multilanguage programs!) or it can be entered directly
REM from your own code if it is a simple affair with no submenus
REM (mostly for "Really do that? (y/n)" type of choices - see the
REM Quit nicely" example in the demo).

REM The first letter or number of each menu item automatically becomes the
REM trigger for that item. ESC exits the menu and restores your screen.
REM It's up to your menu structure to see that no two menu items have the
REM same first letter. Numbering and capitalization works well for this.
REM In fact an ALL-CAPS or all-lowercase menu will see the
REM trigger highlighting and hotkeys messed up.

REM Mouse-aware? ... maybe later, OK?

REM The program does not check if the resulting menu items are too
REM long for the screenwidth. So keep the menu items short!

REM This system will be developed embedded in a demo program for now.
REM When I am satsfied with it, I'll think about making a formal library.
REM This demo itself is a testbed for new ideas, so there are no versions.
REM Just check when Github updates it.

REM Compatibility: QBASIC 1.1 --- OK
REM                QuickBASIC 7 PDS --- no problem
REM                QB64 --- If you can live with those tiny fonts, OK, it works
REM                (Linux)  quite well.
REM                FreeBASIC --- Compiles OK with -lang qb, but goes weird
REM                (Linux)       whenever screen dimensions are called. Charac-
REM                              ter sets would also need to be looked at

REM Bugs: like a rainforest on a hot night.

REM Copy all the global variable declarations below into your program.
REM Sorry, purists, but you are going to need access to them.

REM some arrays to hold the menu structure
COMMON SHARED TuiMenu0$() 'top line
COMMON SHARED TuiMenu1$() 'menu 1
COMMON SHARED TuiMenu2$() 'menu 2
COMMON SHARED TuiMenu3$() 'menu 3
COMMON SHARED TuiMenu4$() 'menu 4
COMMON SHARED TuiMenu5$() 'menu 5

REM TuiMenuScr$ holds the contents of your screen for redrawing
COMMON SHARED TuiMenuScr$

REM colors are not supported yet: TuiMenuScl$ is reserved for future use
REM when it will hold the colors of TuiMenuScr$
REM COMMON SHARED TuiMenuScl$

REM ScrW% and ScrH% hold the screen dimensions. I use them in all my programs
COMMON SHARED ScrW%
COMMON SHARED ScrH%

REM Don't even think of getting TuiMenuType wrong. It MUST be declared
REM for dropdown menus.
COMMON SHARED TuiMenuType% '0 (default) = horizontal: 1 = dropdown

REM TuiMenuTrigger$ is the single most important variable in the program.
REM it is what you will be trapping to decide what to do next.
COMMON SHARED TuiMenuTrigger$

REM copy all the subprograms declared as TuiMenu* into your program,
REM including this block of declarations. You will also need the
REM subprograms called Print* and Gotoxy.

REM the subprograms called Demo* are just for demonstration purposes
DECLARE FUNCTION TuiMenuPickFile$ (TMMessage$, Mask$, Mode%)
DECLARE SUB TuiMenuInputBox (TMMessage$, TheInput$)
DECLARE SUB TuiMenuYesNoBox (TMMessage$, Yes$, No$)
DECLARE SUB PrintAt (x%, y%, text$)
DECLARE SUB TuiMenuRestoreScreenMinus2 ()
DECLARE SUB PrintReverseAt (x%, y%, text$)
DECLARE SUB PrintReverse (text$)
DECLARE SUB TuiMenuDropdown (whichmenu%)
DECLARE SUB gotoxy (x%, y%)
DECLARE SUB TuiMenuInitialize ()
DECLARE SUB TuiMenuFillFromFile (TMFileName$)
DECLARE SUB TUIMenuGetSubmenu (TMFileName$, subm$(), subm%)
DECLARE SUB TuiMenuGetScreen ()
DECLARE SUB TuiMenuRestoreScreen ()
DECLARE SUB TuiMenuCreate (whichmenu%, RightMsg$)
DECLARE SUB TuiMenuDraw (display$, RightMsg$)
DECLARE SUB TuiMenuMsgBox (TMMessage$)
DECLARE SUB TuiMenuHighlight (array$(), array%())
DECLARE SUB DemoRandomColors ()
DECLARE SUB DemoRandomGarbage ()
DECLARE SUB DemoFile (TuiMenuTrigger$)
DECLARE SUB DemoTools (TuiMenuTrigger$)
DECLARE SUB DemoEdit (TuiMenuTrigger$)

REM Start arrays at 1, not 0
REM Yes, I'm old school on this. If you change this you may need to rewrite
REM my routines. Search for "1 TO 5" and change them to "0 TO 4"
OPTION BASE 1

TuiMenuInitialize
CLS
CALL TuiMenuInputBox("Hi there, and welcome to TuiMenu.^What is your name?", name$)
CLS
TuiMenuMsgBox ("Hello, " + name$ + "! We have a great demo for you.^Press a key to continue.")
WHILE INKEY$ = "": WEND
CLS
COLOR 9, 0
TuiMenuMsgBox ("Press any key to fill the screen^with garbage for demonstration purposes")
COLOR 7, 0
WHILE INKEY$ = "": WEND
CALL DemoRandomGarbage
TuiMenuGetScreen
COLOR 4, 0
WelcomeMessage$ = "Press M for menu or Q to quit.^Once your screen is up,^press F1 to access the menu.^Just for laughs. we'll make the^submenus in random colors.^Some combinations work better than others :-)"
REM ran into IDE line length problem here.
WelcomeMessage$ = WelcomeMessage$ + "^^When you are done testing,^Bring up the menu with F1 and then^press ESC to see the other kind of menu."
CALL TuiMenuYesNoBox(WelcomeMessage$, "Menu", "Quit")
WelcomeMessage$ = "" 'save some memory, I hope.
COLOR 7, 0
WHILE a$ = ""
    a$ = INKEY$
    IF LCASE$(a$) = "m" THEN
        TuiMenuFillFromFile ("tuimenu.lst")
       TuiMenuRestoreScreen
    ELSEIF LCASE$(a$) = "q" THEN
        SYSTEM
    ELSE
        a$ = ""
    END IF
WEND

REM just a shortcut to decrease testing time
REM GOTO tempgototarget

REM *******************************************
REM MAIN LOOP1 - all the action happens in here,
REM Mutple points of exit, which would not do
REM in a real program!!!!!
REM *******************************************
TuiMenuType% = 0
F1Key$ = CHR$(0) + CHR$(59)
EscKey$ = CHR$(27)
TuiMenuTrigger$ = F1Key$
WHILE TuiMenuTrigger$ <> EscKey$
    SELECT CASE TuiMenuTrigger$
        CASE F1Key$
            COLOR 7, 0
            CALL TuiMenuCreate(0, "ESC=exit")
        CASE "f", "F"
            CALL TuiMenuCreate(1, "ESC=Back to main screen")
            CALL DemoFile(TuiMenuTrigger$)
        CASE "e", "E"
            CALL TuiMenuCreate(2, "ESC=Back to main screen")
            CALL DemoEdit(TuiMenuTrigger$)
        CASE "t", "T"
            CALL TuiMenuCreate(3, "ESC=Back to main screen")
            CALL DemoTools(TuiMenuTrigger$)
        CASE "h", "H"
            COLOR 7, 0
            TuiMenuMsgBox "This is where help^text would come up if^this was a real program."
            WHILE INKEY$ = "": WEND
            TuiMenuRestoreScreen
            TuiMenuTrigger$ = ""
        CASE EscKey$
            SYSTEM
        CASE ELSE
            WHILE TuiMenuTrigger$ <> F1Key$
                TuiMenuTrigger$ = INKEY$
            WEND
    END SELECT
DemoRandomColors
WEND
REM *******************************************
REM end of main loop 1
REM *******************************************

tempgototarget:
CLS
TuiMenuRestoreScreen
COLOR 2, 0
CALL TuiMenuYesNoBox("Now let's look at a different kind of menu.^Press M for menu or Q to quit.^Unlike the previous example,^this menu stays up permanently.", "Menu", "Quit")
COLOR 7, 0
a$ = ""
WHILE LCASE$(a$) <> "m"
    a$ = INKEY$
    IF LCASE$(a$) = "q" THEN
        SYSTEM
    END IF
WEND
REM ********************************************
REM Main Loop 2
REM ********************************************
TuiMenuType% = 1
F1Key$ = CHR$(0) + CHR$(59)
EscKey$ = CHR$(27)
TuiMenuTrigger$ = ""
COLOR 7, 0
TuiMenuRestoreScreen
CALL TuiMenuCreate(0, "ESC=exit")
WHILE TuiMenuTrigger$ <> EscKey$
    SELECT CASE TuiMenuTrigger$
        CASE "f", "F"
dropdown1:
            CALL TuiMenuDropdown(1)
            IF TuiMenuTrigger$ = "goleft" THEN
                TuiMenuRestoreScreenMinus2
                CALL TuiMenuCreate(0, "ESC=exit")
                TuiMenuTrigger$ = "t"
                GOTO dropdown3
            ELSEIF TuiMenuTrigger$ = "goright" THEN
                TuiMenuRestoreScreenMinus2
                CALL TuiMenuCreate(0, "ESC=exit")
                TuiMenuTrigger$ = "e"
                GOTO dropdown2
            END IF
            CALL DemoFile(TuiMenuTrigger$)
            TuiMenuRestoreScreenMinus2
            CALL TuiMenuCreate(0, "ESC=exit")
dropdown2:
        CASE "e", "E"
            CALL TuiMenuDropdown(2)
            IF TuiMenuTrigger$ = "goleft" THEN
                TuiMenuRestoreScreenMinus2
                CALL TuiMenuCreate(0, "ESC=exit")
                TuiMenuTrigger$ = "f"
                GOTO dropdown1
            ELSEIF TuiMenuTrigger$ = "goright" THEN
                TuiMenuRestoreScreenMinus2
                CALL TuiMenuCreate(0, "ESC=exit")
                TuiMenuTrigger$ = "t"
                GOTO dropdown3
            END IF
            CALL DemoEdit(TuiMenuTrigger$)
            TuiMenuRestoreScreenMinus2
            CALL TuiMenuCreate(0, "ESC=exit")
dropdown3:
        CASE "t", "T"
            CALL TuiMenuDropdown(3)
            IF TuiMenuTrigger$ = "goleft" THEN
                TuiMenuRestoreScreenMinus2
                CALL TuiMenuCreate(0, "ESC=exit")
                TuiMenuTrigger$ = "e"
                GOTO dropdown2
            ELSEIF TuiMenuTrigger$ = "goright" THEN
                TuiMenuRestoreScreenMinus2
                CALL TuiMenuCreate(0, "ESC=exit")
                TuiMenuTrigger$ = "f"
                GOTO dropdown1
            END IF
            CALL DemoTools(TuiMenuTrigger$)
            TuiMenuRestoreScreenMinus2
            CALL TuiMenuCreate(0, "ESC=exit")
        CASE "h", "H"
            COLOR 7, 0
            TuiMenuMsgBox "This is where help^text would come up if^this was a real program."
            WHILE INKEY$ = "": WEND
            TuiMenuRestoreScreenMinus2
            CALL TuiMenuCreate(0, "ESC=exit")
            TuiMenuTrigger$ = ""
        CASE EscKey$
            SYSTEM
        CASE ELSE
            TuiMenuTrigger$ = INKEY$
    END SELECT
WEND
REM *******************************************
REM end of main loop2
REM *******************************************

SYSTEM

SUB DemoEdit (TuiMenuTrigger$)
    IF TuiMenuTrigger$ = "none" THEN EXIT SUB
    EscKey$ = CHR$(27)
    WHILE TuiMenuTrigger$ <> EscKey$
        SELECT CASE TuiMenuTrigger$
            CASE "c", "C"
                TuiMenuMsgBox "This is where a CUT action would^take place if this was a real program."
                WHILE INKEY$ = "": WEND
                TuiMenuTrigger$ = EscKey$
            CASE "p", "P"
                TuiMenuMsgBox "This is where a PASTE action would^take place if this was a real program."
                WHILE INKEY$ = "": WEND
                TuiMenuTrigger$ = EscKey$
            CASE "d", "D"
                TuiMenuMsgBox "This is where a DELETE action would^take place if this was a real program."
                WHILE INKEY$ = "": WEND
                TuiMenuTrigger$ = EscKey$
            CASE ELSE
            TuiMenuTrigger$ = INKEY$
        END SELECT
     WEND
     COLOR 7, 0
     TuiMenuRestoreScreen
     TuiMenuTrigger$ = ""
END SUB

SUB DemoFile (TuiMenuTrigger$)
    IF TuiMenuTrigger$ = "none" THEN EXIT SUB
    EscKey$ = CHR$(27)
    really$ = ""
    WHILE TuiMenuTrigger$ <> EscKey$
        SELECT CASE TuiMenuTrigger$
            CASE "n", "N"
                TuiMenuMsgBox "This would start a new file."
                WHILE INKEY$ = "": WEND
                TuiMenuTrigger$ = EscKey$
            CASE "s", "S"
                TuiMenuRestoreScreen
                aa$ = TuiMenuPickFile$("Please type a filename or press ENTER to cancel:", "*.*", 2)
                TuiMenuRestoreScreen
                IF aa$ <> "" THEN
                    TuiMenuMsgBox "You wanted to save a file called " + aa$
                ELSE
                    TuiMenuMsgBox "OK, let's not save a file, then ..."
                END IF
                WHILE INKEY$ = "": WEND
                TuiMenuTrigger$ = EscKey$
            CASE "o", "O"
                TuiMenuRestoreScreen
                IF TuiMenuType% = 0 THEN
                    aa$ = TuiMenuPickFile$("Please type a directory name or press ENTER to cancel:", "*.", 0)
                ELSE
                    aa$ = TuiMenuPickFile$("Please select a file or press ESC to cancel:", "*.*", 1)
                END IF
                TuiMenuRestoreScreen
                IF aa$ <> "" THEN
                    TuiMenuMsgBox "You wanted to open " + aa$
                ELSE
                    TuiMenuMsgBox "OK, let's not open a file, then ..."
                END IF
                WHILE INKEY$ = "": WEND
                TuiMenuTrigger$ = EscKey$
            CASE "E", "e"
                TuiMenuMsgBox "This demonstrates how to exit a program nicely.^See how the top menu changes."
                WHILE INKEY$ = "": WEND
                CALL TuiMenuDraw("Really Quit? (y/n)", "")
                WHILE really$ = ""
                    really$ = INKEY$
                WEND
                IF (really$ = "Y" OR really$ = "y") THEN
                    SYSTEM
                ELSE
                    TuiMenuTrigger$ = EscKey$
                END IF
            CASE "q", "Q"
                SYSTEM
            CASE ELSE
                TuiMenuTrigger$ = INKEY$
        END SELECT
     WEND
     COLOR 7, 0
     TuiMenuRestoreScreen
     TuiMenuTrigger$ = ""
END SUB

SUB DemoRandomColors
    clr% = INT(RND * 7) + 7
    COLOR clr%, 0
END SUB

SUB DemoRandomGarbage
    totalchars% = ScrW% * ScrH%
    CALL gotoxy(1, 1)
    rndchr% = 32
    FOR f = 1 TO totalchars%
        rndchr$ = CHR$(INT(RND * 95) + 32)
        PRINT rndchr$;
    NEXT f
END SUB

SUB DemoTools (TuiMenuTrigger$)
    IF TuiMenuTrigger$ = "none" THEN EXIT SUB
    EscKey$ = CHR$(27)
    WHILE TuiMenuTrigger$ <> EscKey$
        SELECT CASE TuiMenuTrigger$
            CASE "F", "f"
                COLOR 0, 7
                CLS
                CALL gotoxy(1, 3)
                PRINT "                     The Glorious Fake Program Screen."
                PRINT "                     ================================="
                PRINT
                PRINT
                PRINT "Name: ______________________________"
                PRINT
                PRINT "Adress: _____________________________________________"
                PRINT "        _____________________________________________"
                PRINT "        _____________________________________________"
                PRINT
                PRINT "Tel:    ___ ________"
                PRINT "Cell:   ___ ________"
                PRINT
                PRINT "Website: ____________________________________________"
                PRINT
                PRINT
                PRINT
                IF TuiMenuType% = 0 THEN PRINT "F1=menu"
                TuiMenuGetScreen
                TuiMenuTrigger$ = EscKey$
            CASE "C", "c"
                TuiMenuMsgBox "This option clears the screen."
                WHILE INKEY$ = "": WEND
                CLS
                TuiMenuGetScreen
                TuiMenuTrigger$ = EscKey$
            CASE "N", "n"
                TuiMenuMsgBox "Tired of the old garbage^text in this demo?^Here's some new ones ..."
                WHILE INKEY$ = "": WEND
                COLOR 7, 0
                CALL DemoRandomGarbage
                TuiMenuGetScreen
                TuiMenuTrigger$ = EscKey$
            CASE ELSE
                TuiMenuTrigger$ = INKEY$
        END SELECT
     WEND
     COLOR 7, 0
     TuiMenuRestoreScreen
     TuiMenuTrigger$ = ""
END SUB

SUB gotoxy (x%, y%)
REM ===========================================================================
REM Author: Jason Lashua
REM ok, i hate LOCATE! its BACKWARDS!!!
REM ===========================================================================
    LOCATE y%, x%
END SUB

SUB PrintAt (x%, y%, text$)
REM ===========================================================================
REM I remember this from PRINT AT on Spectrum BASIC
REM coordinates reversed back from the LOCATE confusion to th way they should be
REM For screen 0
REM ===========================================================================
    LOCATE y%, x%
    PRINT text$;
END SUB

SUB PrintReverse (text$)
REM ===========================================================================
REM I remember this from PRINT REVERSE on Spectrum BASIC - for B&W text onl
REM coordinates reversed back from the LOCATE confusion to th way they should be
REM For screen 0
REM ===========================================================================
    COLOR 0, 7
    PRINT text$;
    COLOR 7, 0
END SUB

SUB PrintReverseAt (x%, y%, text$)
REM ===========================================================================
REM I remember this from PRINT REVERSE AT on Spectrum BASIC - for B&W text only
REM coordinates reversed back from the LOCATE confusion to th way they should be
REM For screen 0
REM ===========================================================================
    LOCATE y%, x%
    COLOR 0, 7
    PRINT text$;
    COLOR 7, 0
END SUB

SUB TuiMenuCreate (whichmenu%, RightMsg$)
    DIM array$(5)
    DIM array%(5)
    DIM trigger$(5)
    UpKey$ = CHR$(0) + CHR$(72)
    DownKey$ = CHR$(0) + CHR$(80)
    LeftKey$ = CHR$(0) + CHR$(75)
    RightKey$ = CHR$(0) + CHR$(77)
    EscKey$ = CHR$(27)
    SpaceKey$ = " "
    PageUp$ = CHR$(0) + CHR$(73)
    PageDown$ = CHR$(0) + CHR$(81)
    HomeKey$ = CHR$(0) + CHR$(71)
    EndKey$ = CHR$(0) + CHR$(79)
    InsKey$ = CHR$(0) + CHR$(82)
    DelKey$ = CHR$(0) + CHR$(83)
    EnterKey$ = CHR$(13)
    TabKey$ = CHR$(9)
    sTabKey$ = CHR$(0) + CHR$(15)
    cHomekey$ = CHR$(0) + CHR$(119)
    cEndKey$ = CHR$(0) + CHR$(117)
    cPrtSc$ = CHR$(0) + CHR$(114)
    cLeftKey$ = CHR$(0) + CHR$(115)
    cRightKey$ = CHR$(0) + CHR$(116)
    cPageDown$ = CHR$(0) + CHR$(118)
    cPageUp$ = CHR$(0) + CHR$(132)
    F1Key$ = CHR$(0) + CHR$(59)
    F2Key$ = CHR$(0) + CHR$(60)
    F3Key$ = CHR$(0) + CHR$(61)
    F4Key$ = CHR$(0) + CHR$(62)
    F5Key$ = CHR$(0) + CHR$(63)
    F6Key$ = CHR$(0) + CHR$(64)
    F7Key$ = CHR$(0) + CHR$(65)
    F8Key$ = CHR$(0) + CHR$(66)
    F9Key$ = CHR$(0) + CHR$(67)
    F10Key$ = CHR$(0) + CHR$(68)
    F11Key$ = CHR$(0) + CHR$(133)
    SELECT CASE whichmenu%
        CASE 0
            FOR f = 1 TO 5: array$(f) = TuiMenu0$(f): NEXT f
        CASE 1
            FOR f = 1 TO 5: array$(f) = TuiMenu1$(f): NEXT f
        CASE 2
            FOR f = 1 TO 5: array$(f) = TuiMenu2$(f): NEXT f
        CASE 3
            FOR f = 1 TO 5: array$(f) = TuiMenu3$(f): NEXT f
        CASE 4
            FOR f = 1 TO 5: array$(f) = TuiMenu4$(f): NEXT f
        CASE 5
            FOR f = 1 TO 5: array$(f) = TuiMenu5$(f): NEXT f
    END SELECT
    display$ = ""
    FOR f = 1 TO 5
        IF array$(f) <> "" THEN
            menunr% = menunr% + 1
            trigger$(f) = LCASE$(LEFT$(array$(f), 1))
            display$ = display$ + "  " + array$(f)
            array%(f) = INSTR(display$, LEFT$(array$(f), 1))
        END IF
    NEXT f
    IF menunr% = 0 THEN EXIT SUB
    CALL TuiMenuDraw(display$, RightMsg$)
    IF TuiMenuType% = 1 THEN
        IF TuiMenuTrigger$ = "goleft" OR TuiMenuTrigger$ = "goright" THEN
            EXIT SUB
        END IF
    END IF
    IF TuiMenuType% = 0 THEN CALL TuiMenuHighlight(array$(), array%())
    TuiMenuTrigger$ = ""
    triggered% = 0
    DO UNTIL triggered% = 1
        TuiMenuTrigger$ = INKEY$
        REM make sure that all the special keys and numbers will be passed through
        REM letters are dealt with after this.
        REM the only symbols excuded (from a US keyboard, anyway) are
        REM \ / " ' and `
        REM Those have too much importance in either BASIC or the underlying OS.
        REM But add them if you feel lucky!
        SELECT CASE TuiMenuTrigger$
            CASE UpKey$, DownKey$, LeftKey$, RightKey$, EscKey$, SpaceKey$
                triggered% = 1
            CASE PageUp$, PageDown$, HomeKey$, EndKey$, InsKey$, DelKey$
                triggered% = 1
            CASE EnterKey$, TabKey$, sTabKey$, cHomekey$, cEndKey$, cPrtSc$
                triggered% = 1
            CASE cLeftKey$, cRightKey$, cPageDown$, cPageUp$
                triggered% = 1
            CASE F1Key$, F2Key$, F3Key$, F4Key$, F5Key$
                triggered% = 1
            CASE F6Key$, F7Key$, F8Key$, F9Key$, F10Key$, F11Key$
                triggered% = 1
            CASE "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"
                triggered% = 1
            CASE "!", "@", "#", "$", "%", "^", "*", "(", ")", "_", "-", "+", "=", "{", "}", "[", "]", "|", ":", ";", "<", ">", "?", ",", ".", "~"
                triggered% = 1
        END SELECT
        FOR f = 1 TO menunr%
            REM this LCASE$ below is the reason for all the
            REM SELECT CASE stuff above. LCASE$("1")etc. just give an error.
            IF LCASE$(TuiMenuTrigger$) = LCASE$(trigger$(f)) THEN
                triggered% = 1
            END IF
        NEXT f
    LOOP
END SUB

SUB TuiMenuDraw (display$, RightMsg$)
    spaceleft% = ScrW% - LEN(display$) - 2
    CALL gotoxy(1, 1)
    SELECT CASE TuiMenuType%
        CASE 0
            PRINT SPACE$(ScrW% * 2);
            CALL PrintAt(1, 1, display$)
            CALL gotoxy(LEN(display$) + 1, 1)
            IF LEN(RightMsg$) <= spaceleft% THEN
                PRINT SPACE$(spaceleft% - LEN(RightMsg$));
                PRINT RightMsg$ + "  ";
            END IF
        CASE 1
            CALL PrintReverse(SPACE$(ScrW%))
            CALL PrintAt(1, 2, SPACE$(ScrW%))
            CALL PrintReverseAt(1, 1, display$)
            IF LEN(RightMsg$) < spaceleft% THEN
                CALL gotoxy(ScrW% - LEN(RightMsg$) - 1, 1)
                CALL PrintReverse(RightMsg$)
            END IF
    END SELECT
END SUB

SUB TuiMenuDropdown (whichmenu%)
    DIM array$(5)
    DIM trigger$(5)
    UpKey$ = CHR$(0) + CHR$(72)
    DownKey$ = CHR$(0) + CHR$(80)
    EscKey$ = CHR$(27)
    SpaceKey$ = " "
    EnterKey$ = CHR$(13)
    LeftKey$ = CHR$(0) + CHR$(75)
    RightKey$ = CHR$(0) + CHR$(77)
    SELECT CASE whichmenu%
        CASE 1
            FOR f = 1 TO 5: array$(f) = TuiMenu1$(f): NEXT f
        CASE 2
            FOR f = 1 TO 5: array$(f) = TuiMenu2$(f): NEXT f
        CASE 3
            FOR f = 1 TO 5: array$(f) = TuiMenu3$(f): NEXT f
        CASE 4
            FOR f = 1 TO 5: array$(f) = TuiMenu4$(f): NEXT f
        CASE 5
            FOR f = 1 TO 5: array$(f) = TuiMenu5$(f): NEXT f
    END SELECT
    FOR f = 1 TO ScrW%
         menuline% = SCREEN(1, f)
         menuline$ = menuline$ + CHR$(menuline%)
    NEXT f
    trigger1$ = LEFT$(TuiMenu0$(whichmenu%), 1)
    menustart% = INSTR(menuline$, trigger1$)
    FOR f = 1 TO 5
        IF array$(f) <> "" THEN
            menuitems% = menuitems% + 1
            trigger2$ = LEFT$(array$(f), 1)
            trigger$(f) = LCASE$(trigger2$)
            IF LEN(array$(f)) > maxlen% THEN maxlen% = LEN(array$(f))
        END IF
    NEXT f
    IF menuitems% = 0 THEN EXIT SUB
    FOR f = 1 TO menuitems%
        menuitem$ = array$(f) + SPACE$(maxlen% - LEN(array$(f)))
        CALL PrintReverseAt(menustart% - 1, INT(f + 1), CHR$(179))
        CALL PrintReverseAt(menustart%, INT(f + 1), menuitem$)
        CALL PrintReverseAt(menustart% + maxlen%, INT(f + 1), CHR$(179))
        IF f = menuitems% THEN CALL gotoxy(menustart% - 1, f + 2)
    NEXT f
    CALL PrintReverse(CHR$(192) + STRING$(maxlen%, 196) + CHR$(217))
    choice% = 1
    CALL PrintAt(menustart%, INT(choice%) + 1, array$(choice%) + SPACE$(maxlen% - LEN(array$(choice%))))
    WHILE choice$ = "": choice$ = INKEY$: WEND
    DO
        SELECT CASE choice$
            CASE LeftKey$
                TuiMenuTrigger$ = "goleft"
                EXIT SUB
            CASE RightKey$
                TuiMenuTrigger$ = "goright"
                EXIT SUB
            CASE UpKey$
                CALL PrintReverseAt(menustart%, INT(choice%) + 1, array$(choice%) + SPACE$(maxlen% - LEN(array$(choice%))))
                choice% = choice% - 1
                IF choice% = 0 THEN choice% = menuitems%
                CALL PrintAt(menustart%, INT(choice%) + 1, array$(choice%) + SPACE$(maxlen% - LEN(array$(choice%))))
                choice$ = ""
            CASE DownKey$
                CALL PrintReverseAt(menustart%, INT(choice%) + 1, array$(choice%) + SPACE$(maxlen% - LEN(array$(choice%))))
                choice% = choice% + 1
                IF choice% > menuitems% THEN choice% = 1
                CALL PrintAt(menustart%, INT(choice%) + 1, array$(choice%) + SPACE$(maxlen% - LEN(array$(choice%))))
                choice$ = ""
            CASE EnterKey$
                TuiMenuTrigger$ = LEFT$(array$(choice%), 1)
                TuiMenuRestoreScreenMinus2
                CALL gotoxy(1, 2)
                PRINT SPACE$(ScrW%);
                EXIT SUB
            CASE EscKey$, SpaceKey$
                TuiMenuTrigger$ = "none"
                EXIT SUB
            CASE ELSE
                choice$ = INKEY$
        END SELECT
    LOOP
END SUB

SUB TuiMenuFillFromFile (TMFileName$) STATIC
    IF TuiMenu0$(1) = "" THEN
        f% = FREEFILE
        OPEN TMFileName$ FOR INPUT AS #f%
        WHILE NOT EOF(f%)
            LINE INPUT #f%, menuline$
            IF LCASE$(LEFT$(menuline$, 5)) = ":main" THEN
                FOR f = 1 TO 5
                    LINE INPUT #f%, menuline$
                    IF LCASE$(LEFT$(menuline$, 6)) <> ":/main" THEN
                        TuiMenu0$(f) = menuline$
                    ELSE
                        EXIT FOR
                    END IF
                NEXT f
            END IF
        WEND
        CLOSE #f%
    END IF
    CALL TUIMenuGetSubmenu(TMFileName$, TuiMenu1$(), 1)
    CALL TUIMenuGetSubmenu(TMFileName$, TuiMenu2$(), 2)
    CALL TUIMenuGetSubmenu(TMFileName$, TuiMenu3$(), 3)
    CALL TUIMenuGetSubmenu(TMFileName$, TuiMenu4$(), 4)
    CALL TUIMenuGetSubmenu(TMFileName$, TuiMenu5$(), 5)
EXIT SUB
END SUB

SUB TuiMenuGetScreen
    REM get the current screen and store it in a string
    REM Colours are stored in the second string
    REM but this is reserved for future use.
    REM This only saves the top h-1 lines
    REM if you try to restore them all it scrolls up no matter what you do
    REM but my routines should never touch that line anyway.
    TuiMenuScr$ = ""
    REM TuiMenuScl$ = ""
    FOR f = 1 TO ScrH% - 1
        FOR n = 1 TO ScrW%
            t% = SCREEN(f, n)
            c% = SCREEN(f, n, 1)
            TuiMenuScr$ = TuiMenuScr$ + CHR$(t%)
            REM TuiMenuScl$ = TuiMenuScl$ + CHR$(c%)
        NEXT n
    NEXT f
END SUB

SUB TUIMenuGetSubmenu (TMFileName$, subm$(), subm%)
    IF TuiMenu0$(subm%) = "" THEN EXIT SUB
    f% = FREEFILE
    OPEN TMFileName$ FOR INPUT AS #f%
     WHILE NOT EOF(f%)
        LINE INPUT #f%, menuline$
            IF RTRIM$(menuline$) = ":" + TuiMenu0$(subm%) THEN
                FOR f = 1 TO 5
                    LINE INPUT #f%, menuline$
                    IF RTRIM$(menuline$) = ":/" + TuiMenu0$(subm%) THEN
                        EXIT FOR
                    ELSE
                        subm$(f) = RTRIM$(menuline$)
                    END IF
                NEXT f
                CLOSE #f%
                EXIT SUB
            END IF
        WEND
        CLOSE #f%
END SUB

SUB TuiMenuHighlight (array$(), array%())
    fgcol% = SCREEN(1, 1, 1)
    REM this would be so much simpler if COLOR accepted arguments
    IF fgcol% <= 8 THEN
        hcol% = fgcol% + 8
        COLOR hcol%
    ELSEIF fgcol% <= 15 THEN
        hcol% = fgcol% - 8
        COLOR hcol%
    ELSE
        REM you put blinking text in my menus? I don't know you.
        EXIT SUB
    END IF
    FOR f = 1 TO 5
        IF array$(f) <> "" THEN
            FOR n = 1 TO ScrW% - 1
                vcell% = array%(f)
                CALL gotoxy(vcell%, 1)
            NEXT n
            PRINT LEFT$(array$(f), 1);
        END IF
    NEXT f
    REM now put the color back the way it was
    COLOR fgcol%
END SUB

SUB TuiMenuInitialize
    REM You should only need to run this routine once
    REM Go through this carefully. much of it will affect your entire program.
    REM
    REM Force text mode and 80x25 characters
    REM Damn, doesn't QB have a screensize detection command?
    REM Anyway, changing these to known character modes will enable
    REM different sizes. I will concentrate on 80x25 for development purposes.
    REM In DOS, you might want to back this up with "MODE CO80,25" before you
    REM run this program.
    REM ScrW% = 40: ScrH% = 25 ' watch your menu size!!!!
    REM ScrW% = 40: ScrH% = 43
    REM ScrW% = 40: ScrH% = 50
    REM ScrW% = 80: ScrH% = 43
    REM ScrW% = 80: ScrH% = 50
    REM Update the following 2 variables if you are going to change screensize
    REM Halfway through
    ScrW% = 80: ScrH% = 25
    SCREEN 0
    WIDTH ScrW%, ScrH%
    REM
    REM set RND "seed". By putting it here we only need to do it once
    RANDOMIZE TIMER
    REM
    REM DIM the arrays that will hold the menu contents
    DIM TuiMenu0$(5)
    DIM TuiMenu1$(5)
    DIM TuiMenu2$(5)
    DIM TuiMenu3$(5)
    DIM TuiMenu4$(5)
    DIM TuiMenu5$(5)
    REM
    REM Un-REM any of the following that you are going to need in your program
    REM and paste them where you need them, with COMMON SHARED if required.
    REM These are the keys that QBASIC (or FreeBASIC in qb Mode) can detect with
    REM INKEY$. For FreeBASIC in other modes, you have to replace chr$(0)
    REM with CHR$(255).
    REM
    REM Don't go crazy - QuickBASIC's keyboard scanning is a little primitive
    REM so keep it simple.
    REM
    REM EscKey$ = CHR$(27)
    REM UpKey$ = CHR$(0) + CHR$(72)
    REM DownKey$ = CHR$(0) + CHR$(80)
    REM LeftKey$ = CHR$(0) + CHR$(75)
    REM RightKey$ = CHR$(0) + CHR$(77)
    REM PageUp$ = CHR$(0) + CHR$(73)
    REM PageDown$ = CHR$(0) + CHR$(81)
    REM HomeKey$ = CHR$(0) + CHR$(71)
    REM EndKey$ = CHR$(0) + CHR$(79)
    REM InsKey$ = CHR$(0) + CHR$(82)
    REM DelKey$ = CHR$(0) + CHR$(83)
    REM EnterKey$ = CHR$(13)
    REM TabKey$ = CHR$(9)
    REM with SHift
    REM sTabKey$ = CHR$(0) + CHR$(15)

    REM with CTRL
    REM cHomekey$ = CHR$(0) + CHR$(119)
    REM cEndKey$ = CHR$(0) + CHR$(117)
    REM cPrtSc$ = CHR$(0) + CHR$(114)
    REM cLeftKey$ = CHR$(0) + CHR$(115)
    REM cRightKey$ = CHR$(0) + CHR$(116)
    REM cUpKey$ = CHR$(0) + CHR$(141)
    REM cDownKey$ = CHR$(0) + CHR$(145)
    REM cPageDown$ = CHR$(0) + CHR$(118)
    REM cPageUp$ = CHR$(0) + CHR$(132)
    REM cInsert$ = CHR$(0) + CHR$(146)
    REM cDelete$ = CHR$(0) + CHR$(147)

REM Function Keys

    REM F1Key$ = CHR$(0) + CHR$(59)
    REM F2Key$ = CHR$(0) + CHR$(60)
    REM F3Key$ = CHR$(0) + CHR$(61)
    REM F4Key$ = CHR$(0) + CHR$(62)
    REM F5Key$ = CHR$(0) + CHR$(63)
    REM F6Key$ = CHR$(0) + CHR$(64)
    REM F7Key$ = CHR$(0) + CHR$(65)
    REM F8Key$ = CHR$(0) + CHR$(66)
    REM F9Key$ = CHR$(0) + CHR$(67)
    REM F10Key$ = CHR$(0) + CHR$(68)
    REM F11Key$ = CHR$(0) + CHR$(133)
    REM F12Key$ = CHR$(0) + CHR$(134)

    REM ' Shifted Function Keys

    REM sF1Key$ = CHR$(0) + CHR$(84)
    REM sF2Key$ = CHR$(0) + CHR$(85)
    REM sF3Key$ = CHR$(0) + CHR$(86)
    REM sF4Key$ = CHR$(0) + CHR$(87)
    REM sF5Key$ = CHR$(0) + CHR$(88)
    REM sF6Key$ = CHR$(0) + CHR$(89)
    REM sF7Key$ = CHR$(0) + CHR$(90)
    REM sF8Key$ = CHR$(0) + CHR$(91)
    REM sF9Key$ = CHR$(0) + CHR$(92)
    REM sF10Key$ = CHR$(0) + CHR$(93)
    REM sF11Key$ = CHR$(0) + CHR$(135)
    REM sF12Key$ = CHR$(0) + CHR$(136)

    REM Control Function Keys

    REM cF1Key$ = CHR$(0) + CHR$(94)
    REM cF2Key$ = CHR$(0) + CHR$(95)
    REM cF3Key$ = CHR$(0) + CHR$(96)
    REM cF4Key$ = CHR$(0) + CHR$(97)
    REM cF5Key$ = CHR$(0) + CHR$(98)
    REM cF6Key$ = CHR$(0) + CHR$(99)
    REM cF7Key$ = CHR$(0) + CHR$(100)
    REM cF8Key$ = CHR$(0) + CHR$(101)
    REM cF9Key$ = CHR$(0) + CHR$(102)
    REM cF10Key$ = CHR$(0) + CHR$(103)
    REM cF11Key$ = CHR$(0) + CHR$(137)
    REM cF12Key$ = CHR$(0) + CHR$(138)

    REM Alt Function Keys

    REM aF1Key$ = CHR$(0) + CHR$(104)
    REM aF2Key$ = CHR$(0) + CHR$(105)
    REM aF3Key$ = CHR$(0) + CHR$(106)
    REM aF4Key$ = CHR$(0) + CHR$(107)
    REM aF5Key$ = CHR$(0) + CHR$(108)
    REM aF6Key$ = CHR$(0) + CHR$(109)
    REM aF7Key$ = CHR$(0) + CHR$(110)
    REM aF8Key$ = CHR$(0) + CHR$(111)
    REM aF9Key$ = CHR$(0) + CHR$(112)
    REM aF10Key$ = CHR$(0) + CHR$(113)
    REM aF11Key$ = CHR$(0) + CHR$(139)
    REM aF12Key$ = CHR$(0) + CHR$(140)
END SUB

SUB TuiMenuInputBox (TMMessage$, TheInput$)
    REM Put up a box asking for user input
    REM TheInput$ would normally be left an empty string
    REM use ^ to insert a line break in TMMessage$
    REM After using this routine, you will have to re-LOCATE your cursor
    TMMessage$ = TMMessage$ + "^^^"
    CALL TuiMenuMsgBox(TMMessage$)
    y% = CSRLIN - 3
    CALL gotoxy(3, y%)
    LINE INPUT "? "; TheInput$
END SUB

SUB TuiMenuMsgBox (TMMessage$)
    REM Put up a box with a centred message
    REM use ^ to insert a line break
    REM After using this routine, you will have to re-LOCATE your cursor
    REM
    lines% = 1
    FOR f = 1 TO LEN(TMMessage$)
        IF MID$(TMMessage$, f, 1) = "^" THEN lines% = lines% + 1
    NEXT f
    lines% = lines% + 4 'make space for the borders
    IF lines% > ScrH% THEN TMMessage$ = "Message exceeds screen size"
    lines% = INT((ScrH% - lines%) / 2)
    CALL gotoxy(1, lines%)
    REM print border
    PRINT STRING$(ScrW%, 178)
    REM print an empty line
    PRINT CHR$(178) + SPACE$(ScrW% - 2) + CHR$(178)
    WHILE TMMessage$ <> ""
        IF INSTR(TMMessage$, "^") <> 0 THEN
            WHILE INSTR(TMMessage$, "^") <> 0
                blength% = INSTR(TMMessage$, "^")
                bmessage$ = LEFT$(TMMessage$, blength% - 1)
                TMMessage$ = MID$(TMMessage$, blength% + 1)
                spacer1$ = SPACE$(INT((ScrW% - blength% - 1) / 2))
                spacer2$ = SPACE$(INT(ScrW% - (blength% + LEN(spacer1$))) - 1)
                PRINT CHR$(178) + spacer1$ + bmessage$ + spacer2$ + CHR$(178)
            WEND
        ELSE
            totallength% = LEN(TMMessage$)
            spacer1$ = SPACE$(INT((ScrW% - totallength% - 1) / 2))
            totallength% = totallength% + LEN(spacer1$) + 2
            spacer2$ = SPACE$(ScrW% - totallength%)
            PRINT CHR$(178) + spacer1$ + TMMessage$ + spacer2$ + CHR$(178)
            TMMessage$ = ""
        END IF
    WEND
    REM print an empty line
    PRINT CHR$(178) + SPACE$(ScrW% - 2) + CHR$(178)
    REM print border
    PRINT STRING$(ScrW%, 178);
END SUB

FUNCTION TuiMenuPickFile$ (TMMessage$, Mask$, Mode%)
    REM present a list of files in the current directory
    REM and get the user to select one.

    REM for DOS 8.3 filenames only, no namby-pamby LFNs here.
    REM no spaces or ^ characters allowed in filenames.

    REM Limited to 60 files in 80x25 in mode 0, for it
    REM will crash if there are too many files!
    REM Mode 1 in 80x25 gives you 78 files.
    REM Should be enough for most purposes, but
    REM a higher x resolution will be detected automatically,
    REM and will give more spaces.
    REM You can always adjust y% below, just test carefully.

    REM Mask$ is the normal DOS pattern:
    REM     *.*     = all files and directories
    REM     *.TXT   = text files only
    REM     *.      = directories only  'a DOS convention rather than a hard
                                        'rule, but it's common enough to use.
    REM Mode%  0 = user types name in
    REM        1 = user selects file with cursors
    REM        2 = user types name of new file or directory
    REM            no overwrites allowed.

    IF Mode% = 0 OR Mode% = 2 THEN OriginalTMMessage$ = TMMessage$
    Mask$ = UCASE$(LTRIM$(RTRIM$(Mask$)))
    tempfile$ = ENVIRON$("TMP")
    tempfile$ = tempfile$ + "\TuiMtemp.999"
    SHELL ("dir /b /-p " + Mask$ + " > " + tempfile$)
    x% = INT((ScrW% - 2) / 12)
    IF Mode% = 0 OR Mode% = 2 THEN
        y% = 10
    ELSEIF Mode% = 1 THEN
        y% = 13
    END IF
    counter% = 1
    ff% = FREEFILE
    OPEN tempfile$ FOR INPUT AS #ff%
    DO
        INPUT #ff%, a$
        counter% = counter% + 1
    LOOP UNTIL EOF(ff%)
    CLOSE #ff%
    lines% = INT(counter% / x%)
    OPEN tempfile$ FOR INPUT AS #ff%
    IF lines% > 0 THEN
        FOR f = 1 TO lines%
            b$ = ""
            FOR n = 1 TO x%
                INPUT #ff%, a$
                a$ = UCASE$(LTRIM$(RTRIM$(a$)))
                IF INSTR(a$, "^") THEN a$ = "Illegal flnm" 'no filenames containing ^, sorry.
                IF INSTR(a$, " ") THEN a$ = "Illegal flnm" 'no filenames containing spaces, sorry
                a$ = a$ + SPACE$(13 - LEN(a$))
                b$ = b$ + a$
                counter% = counter% - 1
                NEXT n
            b$ = b$ + "^"
            FileList$ = FileList$ + b$
        NEXT f
    END IF
    IF counter% <> 0 THEN
        b$ = ""
        WHILE NOT EOF(ff%)
            INPUT #ff%, a$
            a$ = UCASE$(LTRIM$(RTRIM$(a$)))
            IF INSTR(a$, "^") THEN a$ = "Illegal Name" 'no filenames containing ^, sorry.
            IF INSTR(a$, " ") THEN a$ = "Illegal flnm" 'no filenames containing spaces, sorry
            a$ = a$ + SPACE$(13 - LEN(a$))
            b$ = b$ + a$
        WEND
        padding% = ScrW% - LEN(b$) - 2
        IF padding% > 12 AND Mask$ = "*." THEN
            b$ = b$ + "..          "
            padding% = padding% - 12
        END IF
            FOR z = 1 TO padding%
                b$ = b$ + " "
            NEXT z
        b$ = b$ + "^"
        FileList$ = FileList$ + b$
        IF Mask$ = "*." AND INSTR(FileList$, "..") = 0 THEN
            FileList$ = FileList$ + ".." + SPACE$(ScrW% - 4) + "^"
        END IF
    END IF
    CLOSE #ff%
    KILL tempfile$
tryagain: 'GOTO target in case user entered something not on the list
    TMMessage$ = TMMessage$ + "^^" + FileList$
    IF Mode% = 0 OR Mode% = 2 THEN
       CALL TuiMenuInputBox(TMMessage$, TheInput$)
    ELSEIF Mode% = 1 THEN
        EscKey$ = CHR$(27)
        EnterKey$ = CHR$(13)
        UpKey$ = CHR$(0) + CHR$(72)
        DownKey$ = CHR$(0) + CHR$(80)
        LeftKey$ = CHR$(0) + CHR$(75)
        RightKey$ = CHR$(0) + CHR$(77)
        REM throw up the message box
        CALL TuiMenuMsgBox(TMMessage$)
        REM find the first file item
        firstfile$ = UCASE$(LEFT$(FileList$, INSTR(FileList$, " ") - 1))
        c% = 2
        FOR R% = 1 TO ScrH%
            IF SCREEN(R%, c%) = ASC(LEFT$(firstfile$, 1)) THEN
                aa$ = ""
                FOR x% = 0 TO 11
                    aa$ = aa$ + CHR$(SCREEN(R%, c% + x%))
                NEXT x%
                aa$ = RTRIM$(aa$)
                IF aa$ = firstfile$ THEN
                    menux% = c%
                    menuy% = R%
                    CALL PrintReverseAt(menux%, menuy%, aa$)
                END IF
            END IF
        NEXT R%
        GOSUB getselectedfile
        WHILE dummy$ = ""
            GOSUB movearound
        WEND
    END IF
    REM exit if ENTER pressed in Mode 0 and 2 (escape routine)
    IF TheInput$ = "" THEN
        TuiMenuPickFile$ = ""
        EXIT FUNCTION
    END IF
    REM Check if the file was one of those displayed (Mode 0 and 2)
    REM this is very rough and ready - it will give a false positive if the
    REM user types a substring of an existing filename
    IF Mode% = 0 THEN
        IF INSTR(UCASE$(FileList$), UCASE$(TheInput$)) = 0 THEN
            TMMessage$ = OriginalTMMessage$
            TuiMenuRestoreScreen
            GOTO tryagain
        ELSE
            TuiMenuPickFile$ = UCASE$(TheInput$)
        END IF
    ELSEIF Mode% = 2 THEN
        IF INSTR(UCASE$(FileList$), UCASE$(TheInput$)) <> 0 THEN
            TMMessage$ = OriginalTMMessage$
            TuiMenuRestoreScreen
            GOTO tryagain
        ELSEIF INSTR(TheInput$, "^") THEN
            GOTO tryagain 'no filenames containing ^, sorry.
        ELSEIF INSTR(TheInput$, " ") THEN
            GOTO tryagain 'no filenames containing spaces, sorry
        ELSE
            TuiMenuPickFile$ = UCASE$(TheInput$)
        END IF
     END IF
EXIT FUNCTION
'########subroutines#########
movearound:
    z$ = INKEY$
    SELECT CASE z$
        CASE EscKey$
            TuiMenuPickFile$ = ""
            EXIT FUNCTION
        CASE EnterKey$
             GOSUB getselectedfile
             TuiMenuPickFile$ = aa$
             EXIT FUNCTION
        CASE UpKey$
            CALL PrintAt(menux%, menuy%, aa$)
            IF SCREEN(menuy% - 1, menux%) <> 32 THEN menuy% = menuy% - 1
            GOSUB getselectedfile
            CALL PrintReverseAt(menux%, menuy%, aa$)
        CASE DownKey$
            CALL PrintAt(menux%, menuy%, aa$)
            IF SCREEN(menuy% + 1, menux%) <> 32 THEN menuy% = menuy% + 1
            GOSUB getselectedfile
            CALL PrintReverseAt(menux%, menuy%, aa$)
        CASE LeftKey$
            CALL PrintAt(menux%, menuy%, aa$)
            IF menux% - 13 > 0 THEN menux% = menux% - 13
            GOSUB getselectedfile
            CALL PrintReverseAt(menux%, menuy%, aa$)
        CASE RightKey$
            CALL PrintAt(menux%, menuy%, aa$)
            IF menux% + 13 < ScrW% THEN menux% = menux% + 13
            GOSUB getselectedfile
            CALL PrintReverseAt(menux%, menuy%, aa$)
    END SELECT
    RETURN
getselectedfile:
    aa$ = ""
    CALL gotoxy(menux%, menuy%)
    FOR x% = 0 TO 11
        aa$ = aa$ + CHR$(SCREEN(menuy%, menux% + x%))
    NEXT x%
    aa$ = RTRIM$(aa$)
    RETURN
END FUNCTION

SUB TuiMenuRestoreScreen
    REM this only restores the top h-1 lines
    REM if you try to do them all it scrolls up no matter what you do
    REM but my routine should never touch that line anyway.
    CALL gotoxy(1, 1)
    PRINT TuiMenuScr$;
    REM FOR f = 1 TO LEN(TuiMenuScr$) - 1
    REM PRINT MID$(TuiMenuScr$, f, 1);
    REM NEXT f
END SUB

SUB TuiMenuRestoreScreenMinus2
    REM same as TuiMenuRestoreScreen, but ignores the first two lines
    REM used whan the menu is permanently onscreen, reduces flickering
    CALL gotoxy(1, 3)
    PRINT MID$(TuiMenuScr$, (ScrW% * 2) + 1);
END SUB

SUB TuiMenuYesNoBox (TMMessage$, Yes$, No$)
    REM Put up a box with two buttons
    REM These don't HAVE to be Yes and NO, but I
    REM had to call it something ...
    REM use ^ to insert a line break in TMMessage$
    REM After using this routine, you will have to re-LOCATE your cursor
    IF Yes$ = "" OR No$ = "" THEN   'not dealing with nulls
        IF TMMessage$ <> "" THEN CALL TuiMenuMsgBox(TMMessage$)
        EXIT SUB
    END IF
    Yes$ = " " + RTRIM$(LTRIM$(Yes$)) + " "
    No$ = " " + RTRIM$(LTRIM$(No$)) + " "
    yeslen% = LEN(Yes$)
    nolen% = LEN(No$)
    REM adjust padding$ below to change layout
    padding$ = SPACE$(5)
    YesNoButtons$ = "^^" + CHR$(201) + STRING$(yeslen%, 205) + CHR$(187) + padding$
    YesNoButtons$ = YesNoButtons$ + CHR$(201) + STRING$(nolen%, 205) + CHR$(187) + "^"
    YesNoButtons$ = YesNoButtons$ + CHR$(186) + Yes$ + CHR$(186) + padding$
    YesNoButtons$ = YesNoButtons$ + CHR$(186) + No$ + CHR$(186) + "^"
    YesNoButtons$ = YesNoButtons$ + CHR$(200) + STRING$(yeslen%, 205) + CHR$(188) + padding$
    YesNoButtons$ = YesNoButtons$ + CHR$(200) + STRING$(nolen%, 205) + CHR$(188) + "^"
    TMMessage$ = TMMessage$ + YesNoButtons$
    CALL TuiMenuMsgBox(TMMessage$)
END SUB

SUB TuiMenuYesNoMaybeBox (TMMessage$, Yes$, No$, Maybe$)
    REM Put up a box with three buttons
    REM These don't HAVE to be Yes, No and Maybe, but I
    REM had to call it something ...
    REM use ^ to insert a line break in TMMessage$
    REM After using this routine, you will have to re-LOCATE your cursor
    IF Yes$ = "" OR No$ = "" OR Maybe$ = "" THEN   'not dealing with nulls
        IF TMMessage$ <> "" THEN CALL TuiMenuMsgBox(TMMessage$)
        EXIT SUB
    END IF
    Yes$ = " " + RTRIM$(LTRIM$(Yes$)) + " "
    No$ = " " + RTRIM$(LTRIM$(No$)) + " "
    Maybe$ = " " + RTRIM$(LTRIM$(Maybe$)) + " "
    yeslen% = LEN(Yes$)
    nolen% = LEN(No$)
    maybelen% = LEN(Maybe$)
    REM adjust padding$ below to change layout
    padding$ = SPACE$(5)
    YesNoButtons$ = "^^" + CHR$(201) + STRING$(yeslen%, 205) + CHR$(187) + padding$
    YesNoButtons$ = YesNoButtons$ + CHR$(201) + STRING$(nolen%, 205) + CHR$(187) + padding$
    YesNoButtons$ = YesNoButtons$ + CHR$(201) + STRING$(maybelen%, 205) + CHR$(187) + "^"
    YesNoButtons$ = YesNoButtons$ + CHR$(186) + Yes$ + CHR$(186) + padding$
    YesNoButtons$ = YesNoButtons$ + CHR$(186) + No$ + CHR$(186) + padding$
    YesNoButtons$ = YesNoButtons$ + CHR$(186) + Maybe$ + CHR$(186) + "^"
    YesNoButtons$ = YesNoButtons$ + CHR$(200) + STRING$(yeslen%, 205) + CHR$(188) + padding$
    YesNoButtons$ = YesNoButtons$ + CHR$(200) + STRING$(nolen%, 205) + CHR$(188) + padding$
    YesNoButtons$ = YesNoButtons$ + CHR$(200) + STRING$(maybelen%, 205) + CHR$(188) + "^"
    TMMessage$ = TMMessage$ + YesNoButtons$
    CALL TuiMenuMsgBox(TMMessage$)
END SUB

