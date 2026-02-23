# Contributing

## Development

1. Clone the repository
2. Install dependencies with `mix deps.get`
3. Run the tests with `mix test`
4. Check formatting with `mix format --check-formatted`

## Publishing a new version

1. Update the `@version` in `mix.exs`
2. Update `CHANGELOG.md` with the changes for the new version
3. Commit the changes and push to `master`
4. Tag the release and push the tag:
   ```
   git tag v<version>
   git push origin v<version>
   ```
5. The `Publish to Hex` GitHub Action will automatically publish the new version to Hex.pm

Note: Publishing requires a `HEX_API_KEY` secret to be configured in the GitHub repository settings.
