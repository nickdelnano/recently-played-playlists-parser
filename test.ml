open Parser
open Utils
open OUnit2
open PlaylistTypes

let test_one ctxt = 
    assert_equal [] []
    
let suite =
  "public" >::: [
      "test_one" >:: test_one;
  ]

let _ = run_test_tt_main suite
