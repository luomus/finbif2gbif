expect_inherits(f2g:::get_license("Public Domain"), "list")

expect_inherits(
  f2g:::get_license(
    "https://creativecommons.org/publicdomain/zero/1.0/legalcode"
  ),
  "list"
)

expect_inherits(
  f2g:::get_license(
    "https://creativecommons.org/licenses/by-nc/4.0/legalcode"
  ),
  "list"
)

expect_inherits(
  f2g:::get_license(
    "https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode"
  ),
  "list"
)

expect_inherits(
  f2g:::get_license(
    "https://creativecommons.org/licenses/by-sa/4.0/legalcode"
  ),
  "list"
)

expect_inherits(
  f2g:::get_license(
    "https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode"
  ),
  "list"
)

expect_inherits(
  f2g:::get_license(
    "https://creativecommons.org/licenses/by-nd/4.0/legalcode"
  ),
  "list"
)
