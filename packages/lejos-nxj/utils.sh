#!/usr/bin/env sh

# Compile, link, upload and run a NXT program
up() {
  filename="$1"
  basename="${filename%.*}"
  nxjc "$filename" \
    && nxj "$basename" ${@:2} \
    && echo -e '\e[32mSuccess' \
    || echo -e '\e[31mFailed'
}

# Compile and run a PC API program
pc() {
  filename="$1"
  basename="${filename%.*}"
  nxjpcc "$filename" \
    && nxj -o "${basename}.nxj" "${basename}" ${@:2} \
    && echo -e '\e[32mSuccess' \
    || echo -e '\e[31mFailed'
}

# Removes .class files generated during compilation
clean() {
  rm -v *.class
}
