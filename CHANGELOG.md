# Changelog

# 2.0.0 (2019-03-22)
Features:

- Added `Month.Period`
- New `Month.Period.shift/2`, `Month.Period.months/2` and `Month.Period.within?/2` that work with both Period and Range structs

Breaking changes:

- Removed `Month.Range.shift/2`, `Month.Range.within?/2` and `Month.Range.months_for_range/2` (see Features)
- Renamed `Month.Range` struct fields `first` and `last` to `start` and `end`

# 1.1.0 (2019-03-21)
- Added `Month.Range.shift/2` method.

# 1.0.0
- First version
