# Used by "mix format"
spark_locals_without_parens = []

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:reactor]
]
