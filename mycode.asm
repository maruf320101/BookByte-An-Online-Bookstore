include emu8086.inc
org 100h
.model large
.stack 1000h 
.data


SIZE EQU 10 
HEAD DB '____Security lock____','$' 
MSG1 DB 13, 10, 'Enter your ID:$'   
MSG2 DB 13, 10, 'Enter your Password:$'
MSG3 DB 13, 10, 'ERROR ID not Found!$'
MSG4 DB 13, 10, 'Wrong Password! Access denied$'
MSG5 DB 13, 10, 'Correct! Welcome to the Safe$'
MSG6 DB 13, 10, 'Too Long password!$'

TEMP_ID DW 1 DUP(?),0 
TEMP_Pass DB 1 DUP(?) 
IDSize = $-TEMP_ID    
PassSize = $-Temp_Pass
ID  DW        'ABIR', 'ANIS', 'FUAD', 'SAKB', 'AB76', 'AN78', 'FD80', 'SK83', '5321', '9876'  
Password DB   1,      2,      3,      4,       7,     10,     11,     13,     12,      14
                                                                    
; Messages
a1 db 10,13,'*******$'
a2 db 10,13,' Welcome $'
a3 db 10,13,' To $'
a4 db 10,13,' Online Book $'
a5 db 10,13,' Shop $'
a6 db 10,13,'*******$'

a7 db 10,13,'Books List---$'
a8 db 10,13,'Enter Your Choice: $'
a9_1 db 10,13,'Enter 1 to Display Books List: $'
a9_2 db 10,13,'1. English Novels$'
a10 db 10,13,'2. BANGLA Novels$'
a11 db 10,13,'3. Islamic Books$'

a34 db 10,13,'Pick Your Book (Choose a number): $'
a35 db 10,13,'Enter Quantity: $'
a36 db 10,13,'Invalid Input !! Try Again$'
a37 db 10,13,'Total Price: $'
continue_prompt db 10,13,'Do you want to buy more books? (1 for Yes, 0 for No): $'
final_total_msg db 10,13,'Final Total for all books: $'

; Book Lists with Prices
a12 db 10,13,'** English Novel List **$'
a13 db 10,13,'1. Wuthering Heights - Rs. 550/-$'
a14 db 10,13,'2. Middle March - Rs. 450/-$'
a15 db 10,13,'3. Nineteen EightyFour - Rs. 650/-$'
a16 db 10,13,'4. The Lord of the Rings - Rs. 750/-$'
a17 db 10,13,'5. Diary of a Nobody - Rs. 350/-$'
a18 db 10,13,'6. His Dark Materials - Rs. 600/-$'

a20 db 10,13,'** BANGLA Novels List **$'
a21 db 10,13,'1. Suhashini - Rs. 400/-$'
a22 db 10,13,'2. Poddoja - Rs. 380/-$'
a23 db 10,13,'3. Tomar sathe - Rs. 420/-$'
a24 db 10,13,'4. Udashin - Rs. 450/-$'

a27 db 10,13,'** Islamic Books List **$'
a28 db 10,13,'1. Minhaj-ul-Muslim - Rs. 850/-$'
a29 db 10,13,'2. Namaz-e-Nabvi - Rs. 600/-$'
a30 db 10,13,'3. Tib-e-Nabvi - Rs. 700/-$'
a31 db 10,13,'4. Hisnul-Muslim - Rs. 500/-$'
a32 db 10,13,'5. Tafseer Ahsan-ul-Bayan - Rs. 1200/-$'
a33 db 10,13,'6. Riyad-us-Saliheen - Rs. 900/-$'

; Price Lists (can be easily modified)
english_prices dw 550, 450, 650, 750, 350, 600  ;english_prices holo level use.
bangla_prices dw 400, 380, 420, 450
islamic_prices dw 850, 600, 700, 500, 1200, 900

; Variables for calculations
total_sum dw 0    
quantity db 0     
current_price dw 0 ; Store price of currently selected book

.code
main proc
    mov ax, @data  
    mov ds, ax      
    
    ; Security Authentication
    
SecurityCheck: 

    ; Display security header
    LEA DX,HEAD ;LEA (Load Effective Address) 
    MOV AH,09H
    INT 21H

ID_PROMPT:  ; level  
    LEA DX,MSG1
    MOV AH,09H
    INT 21H
            
ID_INPUT:  ; level 
    MOV BX,0  
    MOV DX,0
    LEA DI,TEMP_ID 
    MOV DX,IDSize
    CALL get_string 
            
CheckID:    
    MOV BL,0
    MOV SI,0 ; (si) holo source index resistor ja memory acees bha string operation ar jnno use hoy.

AGAIN:       
    MOV AX,ID[SI]  ; memory address theke data read kora hosche.
    MOV DX,TEMP_ID
    CMP DX,AX
    JE  PASS_PROMPT   ;JE (Jump if Equal) hoy tahole pass prompt a chole jabe. 
    INC BL
    ADD SI,4 
    CMP BL,SIZE
    JB  AGAIN
            
ERRORMSG:   
    LEA DX,MSG3
    MOV AH,09H
    INT 21H
    JMP ID_PROMPT
             
PASS_PROMPT:
    LEA DX,MSG2
    MOV AH,09H
    INT 21H
            
Pass_INPUT: 
    CALL   scan_num
    CMP    CL,0FH  
    JAE    TooLong 
    MOV    BH,00H
    MOV    DL,Password[BX] 
    CMP    CL,DL
    JE     CORRECT 
            
INCORRECT:  
    LEA DX,MSG4
    MOV AH,09H
    INT 21H
    JMP ID_PROMPT
            
CORRECT:    
    LEA DX,MSG5
    MOV AH,09H
    INT 21H
    
    ; Initialize total sum after successful login
    mov total_sum, 0

    ; Display welcome screen
    call DisplayWelcome


MainLoop: 
    ; Display categories and get selection
    call DisplayCategories
    
    ; Process book selection and purchase
    call ProcessBookPurchase
    
    ; Ask if user wants to continue
    call AskToContinue
    cmp al, '1'
    je MainLoop
    
    ; Display final total
    call DisplayFinalTotal
    
    mov ah, 4ch
    int 21h

TooLong:    
    LEA DX,MSG6
    MOV AH,09H
    INT 21H
    JMP PASS_PROMPT

main endp

; [All previous procedures from the book store code remain the same]
; Repeat all the procedures from the previous book store code here
; (DisplayWelcome, DisplayCategories, ProcessBookPurchase, etc.)
 DisplayWelcome proc
    mov ah, 9
    mov dx, offset a1
    int 21h
    mov dx, offset a2
    int 21h
    mov dx, offset a3
    int 21h
    mov dx, offset a4
    int 21h
    mov dx, offset a5
    int 21h
    mov dx, offset a6
    int 21h
    ret
DisplayWelcome endp

DisplayCategories proc
    mov ah, 9
    mov dx, offset a9_1
    int 21h
    
    mov ah, 1
    int 21h
    sub al, '0'
    cmp al, 1
    jne Invalid_Input
    
    mov ah, 9
    mov dx, offset a7
    int 21h
    mov dx, offset a9_2
    int 21h
    mov dx, offset a10
    int 21h
    mov dx, offset a11
    int 21h
    
    mov dx, offset a8
    int 21h
    ret
DisplayCategories endp

ProcessBookPurchase proc
    mov ah, 1
    int 21h
    sub al, '0'
    
    cmp al, 1
    je DisplayEnglish
    cmp al, 2
    je DisplayBangla
    cmp al, 3
    je DisplayIslamic
    jmp Invalid_Input
    
ProcessBookPurchase endp

DisplayEnglish proc
    mov ah, 9
    mov dx, offset a12
    int 21h
    mov dx, offset a13
    int 21h
    mov dx, offset a14
    int 21h
    mov dx, offset a15
    int 21h
    mov dx, offset a16
    int 21h
    mov dx, offset a17
    int 21h
    mov dx, offset a18
    int 21h
    
    call GetEnglishBookDetails
    ret
DisplayEnglish endp

DisplayBangla proc
    mov ah, 9
    mov dx, offset a20
    int 21h
    mov dx, offset a21
    int 21h
    mov dx, offset a22
    int 21h
    mov dx, offset a23
    int 21h
    mov dx, offset a24
    int 21h
    
    call GetBanglaBookDetails
    ret
DisplayBangla endp

DisplayIslamic proc
    mov ah, 9
    mov dx, offset a27
    int 21h
    mov dx, offset a28
    int 21h
    mov dx, offset a29
    int 21h
    mov dx, offset a30
    int 21h
    mov dx, offset a31
    int 21h
    mov dx, offset a32
    int 21h
    mov dx, offset a33
    int 21h
    
    call GetIslamicBookDetails
    ret
DisplayIslamic endp

GetEnglishBookDetails proc
    mov ah, 9
    mov dx, offset a34
    int 21h
    
    ; Get book selection
    mov ah, 1
    int 21h
    sub al, '0'
    
    ; Validate input
    cmp al, 1
    jb Invalid_Input
    cmp al, 6
    ja Invalid_Input
    
    ; Get price from array
    dec al          ; Convert 1-based to 0-based index
    mov bl, 2       ; Each price is 2 bytes
    mul bl
    mov si, ax
    mov ax, english_prices[si]
    mov current_price, ax
    
    call GetQuantityAndCalculate
    ret
GetEnglishBookDetails endp

GetBanglaBookDetails proc
    mov ah, 9
    mov dx, offset a34
    int 21h
    
    ; Get book selection
    mov ah, 1
    int 21h
    sub al, '0'
    
    ; Validate input
    cmp al, 1
    jb Invalid_Input
    cmp al, 4
    ja Invalid_Input
    
    ; Get price from array
    dec al          ; Convert 1-based to 0-based index
    mov bl, 2       ; Each price is 2 bytes
    mul bl
    mov si, ax
    mov ax, bangla_prices[si]
    mov current_price, ax
    
    call GetQuantityAndCalculate
    ret
GetBanglaBookDetails endp

GetIslamicBookDetails proc
    mov ah, 9
    mov dx, offset a34
    int 21h
    
    ; Get book selection
    mov ah, 1
    int 21h
    sub al, '0'
    
    ; Validate input
    cmp al, 1
    jb Invalid_Input
    cmp al, 6
    ja Invalid_Input
    
    ; Get price from array
    dec al          ; Convert 1-based to 0-based index
    mov bl, 2       ; Each price is 2 bytes
    mul bl
    mov si, ax
    mov ax, islamic_prices[si]
    mov current_price, ax
    
    call GetQuantityAndCalculate
    ret
GetIslamicBookDetails endp


GetQuantityAndCalculate proc
    ; Get quantity
    mov ah, 9
    mov dx, offset a35
    int 21h
    
    ; Read quantity
    mov ah, 1
    int 21h
    sub al, '0'
    
    ; Validate quantity
    cmp al, 1
    jb Invalid_Input
    cmp al, 9
    ja Invalid_Input
    
    ; Calculate total for this book (price * quantity)
    xor ah, ah      ; Clear AH to ensure clean multiplication
    mov bl, al      ; Store quantity in BL
    mov ax, current_price
    mul bx          ; Multiply price by quantity (result in DX:AX)
    
    ; Add to running total with overflow check
    add total_sum, ax
    jnc no_overflow  ; If no carry, skip adjustment
    mov ax, 0FFFFh  ; If overflow, set to maximum value
    mov total_sum, ax
    
no_overflow:
    ret
GetQuantityAndCalculate endp

AskToContinue proc
    mov ah, 9
    mov dx, offset continue_prompt
    int 21h
    
    mov ah, 1
    int 21h
    ret
AskToContinue endp

DisplayFinalTotal proc
    mov ah, 9
    mov dx, offset final_total_msg
    int 21h
    
    mov ax, total_sum
    call DisplayNumber
    ret
DisplayFinalTotal endp

DisplayNumber proc
    push ax
    push bx
    push cx
    push dx
    
    mov bx, 10
    xor cx, cx      ; Initialize digit counter
    
DigitLoop:
    xor dx, dx
    div bx          ; Divide by 10
    push dx         ; Save remainder
    inc cx          ; Increment counter
    test ax, ax     ; Check if quotient is 0
    jnz DigitLoop
    
    ; Print "Rs. " before the number
    mov dl, 'R'
    mov ah, 2
    int 21h
    mov dl, 's'
    int 21h
    mov dl, '.'
    int 21h
    mov dl, ' '
    int 21h
    
PrintLoop:
    pop dx
    add dl, '0'     ; Convert to ASCII
    mov ah, 2
    int 21h
    loop PrintLoop
    
    mov dl, '/'     ; Print "/- "
    int 21h
    mov dl, '-'
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DisplayNumber endp

Invalid_Input:
    mov ah, 9
    mov dx, offset a36
    int 21h
    jmp MainLoop
; From the previous security code
DEFINE_SCAN_NUM
DEFINE_GET_STRING
   
end main