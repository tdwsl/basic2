REM This is a comment yo

print "Hello, world!"

i = 1
loop1:
  print "Non for loop "; i
  i = i + 1
  if i <= 10 then goto loop1

for i = 1 to 10
  print "For loop ";i
next

s$ = "Hello again, world!"
gosub prints
gosub prints

n = 10 + (2-3) * 20 / -2
print "";n

print "Goodbye!"

exit

prints:
print s$
return
