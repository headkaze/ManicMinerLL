@ Copyright (c) 2009 Proteus Developments / Headsoft
@ 
@ Permission is hereby granted, free of charge, to any person obtaining
@ a copy of this software and associated documentation files (the
@ "Software"),  the rights to use, copy, modify, merge, subject to
@ the following conditions:
@ 
@ The above copyright notice and this permission notice shall be included
@ in all copies or substantial portions of the Software both source and
@ the compiled code.
@ 
@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
@ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
@ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
@ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
@ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
@ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
@ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
		cmp r2,#17
		
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