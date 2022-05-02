
fh = open("starter2.cfg", "r")

line = fh.readline()

level = 0
escape = False
escape_activated_with_this_char = False
result = []
result_position = result
line = ""
for c in line:
    opening = False
    closing = False
    escape_activated_with_this_char = False
    if c == '\\' and not escape:
        escape = True
        escape_activated_with_this_char = True
    if c == '{' and not escape:
        level += 1
        opening = True
    if c == '}' and not escape:
        level -= 1
        closing = True

    print(level)

    if not escape_activated_with_this_char:
        escape = False

