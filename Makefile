all: opavo.exe

opavo.exe: src/base.opa src/chat_pane.opa src/main.opa
	opa src/base.opa src/chat_pane.opa src/main.opa -o opavo.exe

clean:
	\rm -Rf *.exe _build _tracks *.log