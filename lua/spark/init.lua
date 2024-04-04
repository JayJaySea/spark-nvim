require("spark.utils").create_tmpdir()

local M = {}

M.add_reference = require("spark.add_reference").add_reference
M.follow_reference = require("spark.follow_reference").follow_reference
M.open_note = require("spark.open_note").open_note
M.save_note = require("spark.save_note").save_note
M.set_autosave_note = require("spark.save_note").set_autosave_note
M.check_spark = require("spark.utils").check_spark

return M
