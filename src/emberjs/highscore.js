
var LibraryEmberHighscore = {
    ember_get_highscore: function() {
        var str = window.localStorage.getItem('ember_highscore');
        return str ? Number(str) : 0;
    },
    ember_set_highscore: function(newscore) {
        window.localStorage.setItem('ember_highscore', newscore.toString());
    },
};

mergeInto(LibraryManager.library, LibraryEmberHighscore);
