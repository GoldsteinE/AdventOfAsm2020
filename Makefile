TASKS=1

help:
	@echo "make <task number>         # assemble & link task"
	@echo "make <task number>/run     # run the first part of task"
	@echo "make <task number>/run2    # run the second part of task"
	@echo "make <task number>/runex   # run the first part of task on example data"
	@echo "make <task number>/runex2  # run the second part of task on example data"

$(TASKS): $(TASKS)/exe

$(TASKS)/exe: $(TASKS)/obj.o
	ld $(TASKS)/obj.o -o $(TASKS)/exe

$(TASKS)/obj.o: $(TASKS)/code.s
	as $(TASKS)/code.s -o $(TASKS)/obj.o

$(TASKS)/run: $(TASKS)/exe $(TASKS)/inp.txt
	$(TASKS)/exe < $(TASKS)/inp.txt

$(TASKS)/run2: $(TASKS)/exe $(TASKS)/inp.txt
	$(TASKS)/exe - < $(TASKS)/inp.txt

$(TASKS)/runex: $(TASKS)/exe $(TASKS)/example.txt
	$(TASKS)/exe < $(TASKS)/example.txt

$(TASKS)/runex2: $(TASKS)/exe $(TASKS)/example.txt
	$(TASKS)/exe - < $(TASKS)/example.txt

.PHONY: $(TASKS)/run $(TASKS)/run2 $(TASKS)/runex $(TASKS)/runex2 help

