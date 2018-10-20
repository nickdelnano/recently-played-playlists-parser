OCAMLBUILD = ocamlbuild

SOURCES = parser.ml utils.ml playlistTypes.ml
TEST_SOURCES = test.ml

INTERFACE_RESULT = interface.byte
TEST_RESULT = test.byte

OCAMLLDFLAGS = -g
PACKS = oUnit,str

all: $(STUDENT_RESULT) $(INTERFACE_RESULT)

clean:
	rm -f *.byte
	rm -f *.native
	rm -f *.cmi
	rm -f *.cmo
	rm -r _build
	$(OCAMLBUILD) -clean

interface: $(INTERFACE_RESULT)

test: $(STUDENT_RESULT)

$(INTERFACE_RESULT): $(SOURCES) interface.ml eval.ml
	$(OCAMLBUILD) $(INTERFACE_RESULT) -pkgs $(PACKS)

$(STUDENT_RESULT): $(SOURCES) $(STUDENT_SOURCES)
	$(OCAMLBUILD) $(STUDENT_RESULT) -pkgs $(PACKS)
