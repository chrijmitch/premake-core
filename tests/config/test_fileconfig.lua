--
-- tests/config/test_fileconfig.lua
-- Test the config object's file configuration accessor.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.config_fileconfig = { }
	local suite = T.config_fileconfig
	local project = premake5.project
	local config = premake5.config


--
-- Setup and teardown
--

	local sln, prj, fcfg

	function suite.setup()
		sln, prj = test.createsolution()
	end

	local function prepare(filename)
		local cfg = project.getconfig(prj, "Debug")
		fcfg = config.getfileconfig(cfg, path.join(os.getcwd(), filename or "hello.c"))
	end


--
-- A file specified at the project level should be present in all configurations.
--

	function suite.isPresent_onProjectLevel()
		files "hello.c"
		prepare()
		test.isnotnil(fcfg)
	end


--
-- A file specified only in the current configuration should return a value.
--

	function suite.isPresent_onCurrentConfigOnly()
		configuration "Debug"
		files "hello.c"
		prepare()
		test.isnotnil(fcfg)
	end


--
-- A file specified only in a different configuration should return nil.
--

	function suite.isNotPresent_onDifferentConfigOnly()
		configuration "Release"
		files "hello.c"
		prepare()
		test.isnil(fcfg)
	end


--
-- A file specified at the project, and excluded in the current configuration
-- should return nil.
--

	function suite.isNotPresent_onExcludedInCurrent()
		files "hello.c"
		configuration "Debug"
		excludes "hello.c"
		prepare()
		test.isnil(fcfg)
	end


--
-- A file specified at the project, and excluded in a different configuration
-- should return a value.
--

	function suite.isNotPresent_onExcludedInCurrent()
		files "hello.c"
		configuration "Release"
		excludes "hello.c"
		prepare()
		test.isnotnil(fcfg)
	end


--
-- A build option specified on a specific set of files should appear in the
-- file configuration
--

	function suite.settingIsPresent_onFileSpecificFilter()
		files "hello.c"
		configuration "**.c"
		buildoptions "-Xc"
		prepare()
		test.isequal({ "-Xc" }, fcfg.buildoptions)
	end


--
-- A "not" filter should not provide the positive match for a
-- file configuration filename mask.
--

	function suite.fileIsUnmatched_onNotFilter()
		files "hello.c"
		configuration "not Debug"
		buildoptions "-Xc"
		prepare()
		test.isequal({}, fcfg.buildoptions)
	end


--
-- Check case-sensitivity of file name tests.
--

	function suite.fileMatches_onCaseMismatch()
		files "Hello.c"
		configuration "HeLLo.c"
		buildoptions "-Xc"
		prepare("Hello.c")
		test.isequal({ "-Xc" }, fcfg.buildoptions)
	end
	

--
-- A leading single star should match files in the same 
-- folder as the project script, for consistency with files(),
-- but not files in other folders.
--

	function suite.singleStarMatches_onSameFolder()
		files "hello.c"
		configuration "*.c"
		buildoptions "-Xc"
		prepare()
		test.isequal({ "-Xc" }, fcfg.buildoptions)
	end

	function suite.singleStarNoMatch_onDifferentFolder()
		files "src/hello.c"
		configuration "*.c"
		buildoptions "-Xc"
		prepare("src/hello.c")
		test.isequal({}, fcfg.buildoptions)
	end

