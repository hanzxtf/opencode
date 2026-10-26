# Rust clippy lints

Vendored from https://github.com/morganlinton/BeautifulRust (`lints/lints.toml` and
`lints/clippy.toml`), referenced by the `rust-best-practices` and `rust-review` skills.

`lints.toml` is pasted into a crate's `[lints]` table (or `[workspace.lints]`);
`clippy.toml` goes next to `Cargo.toml`. Both need `rust-version` 1.81 or later.

Refresh with:

```bash
git clone --depth 1 https://github.com/morganlinton/BeautifulRust /tmp/br \
  && cp /tmp/br/lints/lints.toml /tmp/br/lints/clippy.toml . \
  && rm -rf /tmp/br
```
