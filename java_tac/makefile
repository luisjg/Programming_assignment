# A simple makefile when developing in Java

# Define some MAKE Variables
JC   = javac
JAVA = java
JSUB = java_subroutine
MSUB = mips_subroutine
RM   = rm -f


# Define a set a rules based upon the suffix of a file
.SUFFIXES:.java .class

% : %.class
	${JAVA} $* 

.java.class:
	${JC} $*.java


# Define the first target (i.e., the default) rule
all: 
	STH_DRIVER=java_subroutine sth_validate ../test_cases


# Define a target, which is not a file, to clean up the directory of temporary files
.PHONEY: clean
clean: 
	${RM} *.class
	${RM} -r .java_subroutine

