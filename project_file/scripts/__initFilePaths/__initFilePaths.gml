//#macro APPDATA_PATH ( ( environment_get_variable( "APPDATA" ) + @"\<GAMEPATHGOESHERE>\" ) )
#macro LOCAL_APPDATA_PATH ( working_directory )
#macro GAME_PATH ( program_directory + @"\" )

#macro APPDATA_PATH ( environment_get_variable( "APPDATA" ) + @"\__LIBRARY_TEST\" )

#macro ROOT_PATH ( program_directory + @"\" )
#macro DATA_PATH ( APPDATA_PATH + @"data\" )
#macro CACHE_PATH ( DATA_PATH + @"cache\" )
#macro BULB_PATH ( CACHE_PATH + @"bulb\" )

#macro CONFIG_PATH ( DATA_PATH + @"config\" )
#macro RESOURCE_PATH ( DATA_PATH + @"resource\" )
#macro LOGS_PATH ( DATA_PATH + @"logs\" )
#macro PROFILE_PATH ( DATA_PATH + @"profiles\" )
#macro SAVE_PATH ( PROFILE_PATH + $"{0}" + "/saves" )

#macro LANG_PATH ( CONFIG_PATH + @"lang\" )
#macro SFX_PATH ( RESOURCE_PATH + @"sfx\" )
#macro MUSIC_PATH ( RESOURCE_PATH + @"music\" )

print( "initializing game directories" );

// Init Game Config
directory_create( APPDATA_PATH + "\\data\\" );
directory_create( DATA_PATH + "\\resource\\" );
directory_create( DATA_PATH + "\\config\\" );
directory_create( DATA_PATH + "\\logs\\" );
directory_create( CONFIG_PATH + "\\lang\\" );
directory_create( RESOURCE_PATH + "\\sfx\\" );
directory_create( RESOURCE_PATH + "\\music\\" );