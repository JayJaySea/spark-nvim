require("spark.utils").create_tmpdir()

local M = {}

M.add_note_reference = require("spark.add_reference").add_note_reference
M.follow_reference = require("spark.follow_reference").follow_reference
M.save_note = require("spark.save_note").save_note
M.set_autosave_note = require("spark.save_note").set_autosave_note



return M
