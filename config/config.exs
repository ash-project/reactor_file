import Config

config :spark, formatter: [remove_parens?: true]

config :git_ops,
  mix_project: Reactor.File.MixProject,
  changelog_file: "CHANGELOG.md",
  repository_url: "https://github.com/ash-project/reactor_file",
  manage_mix_version?: true,
  manage_readme_version: true,
  version_tag_prefix: "v"
