build target:
	as "{{target}}/code.s" -o "{{target}}/obj.o"
	ld "{{target}}/obj.o" -o "{{target}}/exe"

run target: (build target)
	"{{target}}/exe" < "{{target}}/inp.txt"

run2 target: (build target)
	"{{target}}/exe" - < "{{target}}/inp.txt"

runex target: (build target)
	"{{target}}/exe" < "{{target}}/example.txt"

runex2 target: (build target)
	"{{target}}/exe" - < "{{target}}/example.txt"

runstd target: (build target)
	"{{target}}/exe"

runstd2 target: (build target)
	"{{target}}/exe" -

dbg target: (build target)
	#!/bin/sh
	if type ugdb >/dev/null; then
		ugdb "{{target}}/exe"
	else
		gdb "{{target}}/exe"
	fi
