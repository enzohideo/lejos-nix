#!/usr/bin/env sh

# Compile, link, upload and run a NXT program
up() {
  filename="$1"
  basename="${filename%.*}"
  nxjc "$filename"
  nxj -r "$basename"
}

# Compile and run a PC API program
pc() {
  filename="$1"
  basename="${filename%.*}"
  nxjpcc "$filename"
  nxjpc "$basename"
}

# Removes .class files generated during compilation
clean() {
  rm -v *.class
}
