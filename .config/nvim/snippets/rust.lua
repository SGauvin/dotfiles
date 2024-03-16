local ls = require("luasnip")
local s = ls.s
local i = ls.i
local t = ls.t
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

local function return_type_choices()
  return {
    t(""),
    fmt(" -> {}", { i(1, "") }),
    fmt(" -> Result<{}, {}>", { i(1, ""), i(2, "") }),
    fmt(" -> Option<{}>", { i(1, "") }),
  }
end

local function function_fmt_str()
  return [[
fn {}({}){} {{
    {}
}}
  ]]
end

local function function_nodes()
  return {
    i(1, "foo"), -- name
    i(2, ""), -- parameters
    c(3, return_type_choices()), -- return type
    i(0, "todo!();"), -- body
  }
end

local function_snip = s("fn", fmt(function_fmt_str(), function_nodes()))
local pub_function_snip = s("pfn", fmt("pub " .. function_fmt_str(), function_nodes()))

local enum_snip = s(
  "enum",
  fmt(
    [[
{}enum {} {{
    {}
}}
    ]],
    {
      c(1, {
        t({ "#[derive(Debug)]", "" }),
        t(""),
        t({ "#[derive(Debug, Clone)]", "" }),
        t({ "#[derive(Debug, Clone, Copy)]", "" }),
      }),
      i(2, "EnumName"),
      i(3, "// Variants"),
    }
  )
)

local test_snip = s(
  "test",
  fmt(
    [[
#[cfg(test)]
mod tests {{
    #[test]
    fn {}() {{
      {}
    }}
}}
    ]],
    {
      i(1, "test_name"),
      i(2, "// Content"),
    }
  )
)

return {
  function_snip,
  pub_function_snip,
  enum_snip,
  test_snip,
}, {}
