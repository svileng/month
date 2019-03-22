# Month [![hex.pm](https://img.shields.io/hexpm/v/month.svg?style=flat-square)](https://hex.pm/packages/month) [![hexdocs.pm](https://img.shields.io/badge/docs-latest-green.svg?style=flat-square)](https://hexdocs.pm/month)

Library focused on working with months, rather than full dates or dates with time.

## Installation

[Available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `month` to your list of dependencies:

```elixir
def deps do
  [
    {:month, "~> 2.0"}
  ]
end
```

## Usage

Full documentation is published here: [https://hexdocs.pm/month](https://hexdocs.pm/month).

However, here is a small sample:

```ex
iex> import Month.Sigils
Month.Sigils

iex> Month.utc_now!()
~M[2019-03]

iex> ~M[2019-03].month
3

iex> ~M[2019-03].year
2019

iex> range = Month.Range.new!(~M[2019-01], ~M[2019-03])
#Month.Range<~M[2019-01], ~M[2019-03]>

iex> range.months
[~M[2019-01], ~M[2019-02], ~M[2019-03]]
```

## About

<img src="http://cdn.heresy.io/media/logo.png" alt="Heresy logo" width=300>

This project is sponsored by [Heresy](http://heresy.io). We're always looking for great engineers to join our team, so if you love Elixir, open source and enjoy some challenge, drop us a line and say hello!

## License

- Month: See LICENSE file.
- "Heresy" name and logo: Copyright © 2019 Heresy Software Ltd
