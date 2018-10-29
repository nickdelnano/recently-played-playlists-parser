OCAMLBUILD = ocamlbuild

SOURCES = parser.ml utils.ml playlistTypes.ml http.ml
TEST_SOURCES = tests/parser_test.ml

INTERFACE_RESULT = interface.byte
TEST_RESULT = tests/parser_test.byte

OCAMLLDFLAGS = -g
PACKS = str,yojson,cohttp-lwt-unix
TEST_PACKS = oUnit

all: $(TEST_RESULT) $(INTERFACE_RESULT)

clean:
	rm -f *.byte
	rm -f *.native
	rm -f *.cmi
	rm -f *.cmo
	rm -r _build
	$(OCAMLBUILD) -clean

interface: $(INTERFACE_RESULT)

test: $(TEST_RESULT)

$(INTERFACE_RESULT): $(SOURCES) interface.ml eval.ml
	$(OCAMLBUILD) $(INTERFACE_RESULT) -pkgs $(PACKS)

$(TEST_RESULT): $(SOURCES) $(TEST_SOURCES)
	$(OCAMLBUILD) $(TEST_RESULT) -pkgs $(TEST_PACKS)
