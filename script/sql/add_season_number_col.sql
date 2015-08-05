ALTER TABLE main.league ADD COLUMN season_number INT NOT NULL DEFAULT 1;
ALTER TABLE main.rounds ADD COLUMN season_number INT NOT NULL DEFAULT 1;
ALTER TABLE main.schedule ADD COLUMN season_number INT NOT NULL DEFAULT 1;

CREATE TABLE main.league_copy(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player TEXT NOT NULL,
    score INT NOT NULL DEFAULT 0,
    played INT NOT NULL DEFAULT 0,
    won INT NOT NULL DEFAULT 0,
    drawn INT NOT NULL DEFAULT 0,
    lost INT NOT NULL DEFAULT 0,
    for INT NOT NULL DEFAULT 0,
    against INT NOT NULL DEFAULT 0,
    points_diff INT NOT NULL DEFAULT 0,
    season_number INT NOT NULL DEFAULT 1
);

INSERT INTO main.league_copy (player,score,played,won,drawn,lost,for,against,points_diff,season_number)
   SELECT player,score,played,won,drawn,lost,for,against,points_diff,season_number FROM main.league;
DROP TABLE main.league;
ALTER TABLE main.league_copy RENAME TO league;
