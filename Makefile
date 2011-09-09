all: opavo.exe

opavo.exe: src/main.opa
	opa src/main.opa -o opavo.exe

clean:
	\rm -Rf *.exe _build _tracks *.log