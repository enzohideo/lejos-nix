#!/usr/bin/env sh

# Compile, link, upload and run a NXT program
up() {
  filename="$1"
  basename="${filename%.*}"
  nxjc "$filename" ${@:2} \
    && nxj -o "${basename}.nxj" "${basename}" \
    && echo -e '\e[32mSuccess' \
    || echo -e '\e[31mFailed'
}

# Compile and run a PC API program
pc() {
  filename="$1"
  basename="${filename%.*}"
  nxjpcc "$filename" ${@:2} \
    && nxjpc "$basename" \
    && echo -e '\e[32mSuccess' \
    || echo -e '\e[31mFailed'
}

# Removes .class and .nxj files generated during compilation
clean() {
  rm -v *.class *.nxj
}
