Checkmate::Style.create(/\.rb$/) do
  rule /(;)$/, "A line should not end with a semicolon."
  rule /^.{110}(.).*$/, "A line should not be more than 110 characters."
  rule /[@\$a-z\d]+([A-Z])[\w]*\s+=\s+/,
       "Variable names should be underscore-separated, not camel-case (no caps)."
  rule /def [a-z\d\.]+([A-Z])\S*/, "Method names should be underscore-separated, not camel-case (no caps)."
  rule /\s(do) \|.*end/, "Use {...} instead of do...end for single-line blocks."
  rule [/\S({)\s*\|/, /\S\s*({)\|/], "Braces should be padded with space on both sides."
  rule /^\s*#([\w])/, "Put a space after the # in a comment."
  rule /^\s*(\t)/, "Ruby files should not be indented with tabs (only spaces)."
end
