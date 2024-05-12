/* 
    The Music Track Class.
    Contains the individual parts of a music track; Drums, Lead, etc.
    Also contains data like track length, track name and BPM.
*/
function cMusicTrack() class {
    bpm = 163;
    bpms = 60000 / bpm;
    stems = {};
    
    static GetBPM = function() {
        return bpm;
    } 
    static GetBPMS = function() {
        return bpms;
    }    
    static GetStems = function() {
        return stems;
    }
}