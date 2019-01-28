OCAMLBUILD = ocamlbuild

SOURCES = parser.ml utils.ml playlistTypes.ml http.ml
TEST_SOURCES = tests/parser_test.ml

MAIN_RESULT = main.byte
TEST_RESULT = tests/parser_test.byte

OCAMLLDFLAGS = -g
PACKS = str,cohttp-lwt-unix
TEST_PACKS = oUnit

all: $(TEST_RESULT) $(MAIN_RESULT)

clean:
	rm -f *.byte
	rm -f *.native
	rm -f *.cmi
	rm -f *.cmo
	rm -r _build
	$(OCAMLBUILD) -clean

main: $(MAIN_RESULT)

test: $(TEST_RESULT)

$(MAIN_RESULT): $(SOURCES) main.ml eval.ml
	$(OCAMLBUILD) $(MAIN_RESULT) -pkgs $(PACKS)

$(TEST_RESULT): $(SOURCES) $(TEST_SOURCES)
	$(OCAMLBUILD) $(TEST_RESULT) -pkgs $(TEST_PACKS)
