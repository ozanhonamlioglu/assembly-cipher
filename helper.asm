%include "def.asm"

; lengthOfString fonksiyonu bittiğinde, uzunluk r8 içerisinde olacak.
%macro lengthOfString 1
    ; string'in karakter sayısını bulabilmek için 0 rakamını bulana kadar döngü yaratacağız
    mov r8, 0 ; counter'ı sıfır'a eşitledik
    mov rax, %1 ; rax'i string'e pointer olarak kullanıyoruz
    %%findLengthOfString:
        inc r8 ; her döngü de counter'imiz olan r8'i +1 yapıyoruz
        inc rax ; pointer'in değerini de +1 yapıyoruz ki, string'i tarayabilelim
        cmp [rax], byte 0 ; rax'in point etmiş olduğu değer'i sıfır ile karşılaştırıyoruz
        jnz %%findLengthOfString
%endmacro

%macro printString 1
    lengthOfString %1
    simplePrint %1, r8
%endmacro

%macro printDigit 1
    ; bölümden sonra rakamları spacePos içerisinde tersten tutuyor olacağız: spacePos: 10, 2, 1
    mov rax, %1 ; bölünecek olan sayı
    mov rdi, 10 ; bölen
    mov r8, 0 ; bölüm boyunca kaç kez işlem yapıldığını tuttuğumuz counter
    mov r10, digitSpace
    mov [r10], byte 10 ; yeni satır karakteri
    inc r8

    ; *** Kalan rdx register'i içerisinde tutulur
    %%storeDigitsBackwards:
        inc r10 ; r10 registerini her işlemde bir arttırıyoruz, spacePos'un içerisinde 1'er arttırarak geziyoruz
        inc r8 ; aynı şekilde yapılan işlem sayısını tutmak için counter'ımızı da arttırıyoruz
        div rdi ; bölenimiz rdi, içinde 10 değerini barındırıyor: 1010
        add rdx, 48 ; kalan'a 48 ekliyoruz, ASCII tablosunda rakamlar 48 den başlıyor: 48: 0, 49: 1, 50: 2
        mov [r10], rdx ; digitSpace'in +1 yani boş adresine elde ettiğimiz rakamı koyuyoruz
        xor rdx, rdx ; rdx'i sıfırlamayı unutmayalım, günün sonunda rax ile birleştiriliyorlar, ortaya istenmeyen veriler çıkıyor
        cmp rax, 0 ; bölüm'ü 0 ile karşılaştırıyoruz, sıfır kalana dek bölme işlemi yapacağız
        jnz %%storeDigitsBackwards ; ALU ZF (zero flag) yaktığında değerler eşit demektir

    ; digitSpace içerisinde ki değerleri ekrana byte byte yazdırıyoruz
    %%printDigitByDigit:
        simplePrint r10, 1 ; her seferinde r10 içerisinde ki bir byte'lık değeri yazdırıyoruz
        dec r10 ; r10 adresini de her döngü de küçültüyoruz
        dec r8 ; r8 ile de sıfır'a varana kadar işlem döngü tanımlıyor olacağız
        cmp r8, 0 ; r8 sıfır'a vardı mı ?
        jnz %%printDigitByDigit
%endmacro

%macro simplePrint 2
    mov rax, SYS_WRITE
    mov rdi, STD_OUT
    mov rsi, %1 ; string'in kendisi
    mov rdx, %2 ; basılacak olan verinin uzunluğu
    syscall
    xor rdx, rdx ; yazma işlemi sonunda print subroutine'nin uzunluk parametresi olan rdx'i sıfırlıyoruz, aksi halde hatalara yol açıyor. (Floating point exception)
%endmacro

%macro encrypte 0
    pop rcx ; argüman sayısını aldık stack den
    pop rcx ; programın exe adını aldık yine stack den
    pop rcx ; şimdi esas şifrelemek istediğimiz parametremizi çekiyoruz yine stack den. Diğer veriler işimize yaramayacağı için sürekli olarak rcx üzerinde override yaptık
    mov rsi, crypetedString ; crypetedString değişkeninin ilk adres'ini rsi içine ekliyoruz ki hep +1 değer ötesine veri ekleyelim
    %%pushIntoSpace:
        add [rcx], byte 3 ; rcx içerisinde ki değer'e +3 ekledik
        mov r10, [rcx] ; rcx'in point etmiş olduğu değeri r10'a yükledik
        mov [rsi], r10 ; şimdi crypetedString içine r10'u yani esas değeri gömüyoruz
        inc rsi ; rsi +1 leyerek crypetedString arazisinde ilerliyoruz
        inc rcx ; rcx +1 leyerek argüman'ın karakterlerini okuyoruz
        cmp [rcx], byte 0 ; arümanlara otomatik olarak sonlandırma rakamı olan 0 eklenir, 0'ı bulana kadar da döngü yaratıyoruz
        jnz %%pushIntoSpace
        mov [rsi], byte 0 ; en son olarak, crypetedString içerisine eklediğimiz karakterlerin sonuna da 0 ekleyerek işi bitiriyoruz.
        lengthOfString crypetedString ; bu fonksiyonun sonunda r8 modifiye edilmiş durumda olacak, bunu kullanabiliriz.
        mov [lengthOfCryptedString], r8
        writeIntoFile
%endmacro

%macro openFile 0
    mov rax, SYS_OPEN
    mov rdi, filename
    mov rsi, O_CREATE+O_WRONLY
    mov rdx, 0644o ; o tells the NASM this is an octal value
    syscall
%endmacro

%macro closeFile 0
    mov rax, SYS_CLOSE
    pop rdi
    syscall
%endmacro

%macro writeIntoFile 0
    openFile
    push rax
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, crypetedString
    mov rdx, [lengthOfCryptedString]
    syscall
    closeFile
%endmacro

%macro exitProgram 0
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
%endmacro