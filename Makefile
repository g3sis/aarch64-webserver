# Define the assembler and linker, using standard variables
AS = as
LD = ld

# Define the source file, object file, and final executable name
SRC = server.s
OBJ = server.o
TARGET = server

# The default target to be built when you run 'make'
all: $(TARGET)

# Rule to link the object file into the final executable
$(TARGET): $(OBJ)
	$(LD) -o $(TARGET) $(OBJ)

# Rule to assemble the source file into an object file
$(OBJ): $(SRC)
	$(AS) -g -o $(OBJ) $(SRC)

# Rule to clean up build artifacts
clean:
	rm -f $(TARGET) $(OBJ)

# Phony targets are not actual files
.PHONY: all clean
