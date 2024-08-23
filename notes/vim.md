# Vim ale with C

```bash
apt install clang clangd bear build-essential

# Inside project directory, write this Makefile
# and run
make clean; bear -- make

# This should make a compile_commands.json file, for clangd or ccls to recognize

# One can also just add a empty [] json file...
```

```make
CC = gcc
CFLAGS = -Wall -Wextra -O2
TARGET = 1
SRC = 1.c
all: $(TARGET)

$(TARGET): $(SRC)
    $(CC) $(CFLAGS) -o $(TARGET) $(SRC)

clean: rm -f $(TARGET)

.PHONY: all clean
```
