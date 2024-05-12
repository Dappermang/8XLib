/* 
    The Music Player Class.
    Plays a SONG and can control the fadeins, fadeouts and gain of a given Music Track data.
    
    BPM System;
    - Song can have multiple 'phases'
    - Song can fadein/fadeout instruments at the next desired beat.
    
    EVENTS ;
    - Songs should be able to be affected by ingame or otherwise events.
    - Events should be small little 'packets' of data that contain function calls relating to the stems they are affecting.
*/
function cMusicPlayer() class {
    track = new cMusicTrack();
    volume = 1;
    beatsCounted = 0;
    timer = 4;
    
    static FadeIn = function( stemName, resolution ) {
        
    }    
    static FadeOut = function( stemName, resolution ) {
        
    }
    static SetStemGain = function( stemName, resolution ) {
        
    }
    
    static TickBegin = function() {
    }
    static Tick = function() {
        var _trackBPMS = track.GetBPMS();
        
        //beatsCounted = round( beatDelta / _trackBPMS ) % 4;
    }
}