expect_equal(
  f2g:::paste_type_status(
    TRUE, "http://tun.fi/MY.typeStatusType", "a", "b"
  ),
  "Type of a b"
)
