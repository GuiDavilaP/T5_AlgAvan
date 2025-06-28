CXX = g++
CXXFLAGS = -O3 -Wall -I./inc
OBJDIR = obj
SRCDIR = src

# Ensure obj directory exists
$(shell mkdir -p $(OBJDIR))

# Target executable
TARGET = simpleSolver

# Source and object files
SRC = $(SRCDIR)/simpleSolver.cpp
OBJ = $(OBJDIR)/simpleSolver.o

# Main target
$(TARGET): $(OBJ)
	$(CXX) $(OBJ) -o $(TARGET)

# Compile source files to object files
$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: clean

clean:
	rm -f $(OBJDIR)/*.o $(TARGET)