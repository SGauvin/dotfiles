local ls = require("luasnip")
local s = ls.s
local i = ls.i
local t = ls.t
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

local return_type_choices = {
  t(""),
  fmt(" -> {}", { i(1, "") }),
  fmt(" -> Result<{}, {}>", { i(1, ""), i(2, "") }),
  fmt(" -> Option<{}>", { i(1, "") }),
}

local function_snip = s(
  "fn",
  fmt(
    [[
fn {}({}){} {{
    {}
}}
  ]],
    {
      i(1, "foo"), -- name
      i(2, ""), -- parameters
      c(3, return_type_choices), -- return type
      i(0, "todo!();"), -- body
    }
  )
)

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

return {
  function_snip,
  enum_snip,
}, {}
