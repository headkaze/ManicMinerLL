@ Copyright (c) 2009 Proteus Developments / Headsoft
@ 
@ Permission is hereby granted, free of charge, to any person obtaining
@ a copy of this software and associated documentation files (the
@ "Software"), to deal in the Software without restriction, including
@ without limitation the rights to use, copy, modify, merge, publish,
@ distribute, sublicense, and/or sell copies of the Software, and to
@ permit persons to whom the Software is furnished to do so, subject to
@ the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included
@ in all copies or substantial portions of the Software.
@ 
@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
@ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
@ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
@ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
@ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
@ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
@ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "mmll.h"
#include "system.h"
#include "video.h"
#include "background.h"
#include "dma.h"
#include "interrupts.h"
#include "sprite.h"
#include "ipc.h"

	.global levelStory
	
	.arm
	.align
	.text

levelStory:

	stmfd sp!, {r0-r10, lr}
	
	ldr r5,=levelNum
	ldr r5,[r5]
	sub r5,#1
	ldr r1,=312
	mul r5,r1
	ldr r0,=storyText
	add r0,r5						@ r10 = pointer to start of text (286 bytes)
	mov r3,#0						@ draw to main screen
	
	mov r2,#5						@ y pos
	mov r1,#3						@ x pos	
	mov r4,#26

	storyLoop:
	
		bl drawTextBlack
		add r2,#1
		add r0,#26
		cmp r2,#19
		
	bne storyLoop
	
	@ draw level info
	
	ldr r5,=levelNum
	ldr r5,[r5]
	sub r5,#1
	mov r2,#28
	mul r5,r2
	ldr r0,=levelInfo
	add r0,r5
	mov r1,#3
	mov r2,#19
	mov r3,#0
	
	bl drawTextBlack
	
	ldmfd sp!, {r0-r10, pc}
	
	.data
	.align
	
	storyText:
	@ 1
	.ascii "  ON A STORMY NIGHT, WILLY"
	.ascii "FINALLY RETURNS HOME AFTER"
	.ascii "HIS RECENT EXPLOITS IN THE"
	.ascii "MINE.                     "
	.ascii "  SADLY, HE HAS LEFT HIS  "
	.ascii "KEYS SOMEWHERE IN THE MINE"
	.ascii "AND THE ONLY WAY TO ENTER "
	.ascii "HIS HOUSE IS THROUGH THE  "
	.ascii "ROOF.                     "
	.ascii "  THE APPLES LOOK SWEET,  "
	.ascii "IF ONLY IT WASN'T WITCHING"
	.ascii "HOUR...                   "
	@ 2
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "  THIS LEVEL IS JUST FOR  "
	.ascii "     TESTING PURPOSES     "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "

	@ 3
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 4
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 5
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 6
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 7
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 8
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 9
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 10
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 11
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 12
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 13
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "	
	@ 14
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 15
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 16
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 17
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 18
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 19
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 20
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	@ 21
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "
	.ascii "                          "	
	
levelInfo:
	.ascii "    LEVEL 17 - ORIC 1983    "
	.ascii "  LEVEL 1 - SPECTRUM  1983  "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "
	.ascii "LEVEL 17 - ORIC 1983        "