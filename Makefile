CXX = g++
CXXFLAGS = -O3 -Wall -I./inc
OBJDIR = obj
SRCDIR = src
BINDIR = bin

# Ensure obj and bin directories exist
$(shell mkdir -p $(OBJDIR))
$(shell mkdir -p $(BINDIR))

# Target executables
SIMPLE_TARGET = $(BINDIR)/simpleSolver
PROB_TARGET = $(BINDIR)/probSolver

# Source and object files
SIMPLE_SRC = $(SRCDIR)/simpleSolver.cpp
SIMPLE_OBJ = $(OBJDIR)/simpleSolver.o
PROB_SRC = $(SRCDIR)/probSolver.cpp
PROB_OBJ = $(OBJDIR)/probSolver.o

# Default target builds both
all: $(SIMPLE_TARGET) $(PROB_TARGET)

# Individual targets
$(SIMPLE_TARGET): $(SIMPLE_OBJ)
	$(CXX) $(SIMPLE_OBJ) -o $(SIMPLE_TARGET)

$(PROB_TARGET): $(PROB_OBJ)
	$(CXX) $(PROB_OBJ) -o $(PROB_TARGET)

# Compile source files to object files
$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: clean all simple probabilistic

# Convenience targets
simple: $(SIMPLE_TARGET)
probabilistic: $(PROB_TARGET)

clean:
	rm -f $(OBJDIR)/*.o $(SIMPLE_TARGET) $(PROB_TARGET)