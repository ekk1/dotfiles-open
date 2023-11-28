import secrets
import string

base = string.ascii_letters + string.digits
pp = ""

for ii in range(0, 20):
    pp += secrets.choice(base)

print(pp)
