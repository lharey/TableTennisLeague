CREATE TABLE main.league(
    id INTEGER PRIMARY KEY AUTOINCREMENT
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

CREATE TABLE main.rounds(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    round INT NOT NULL,
    player1 TEXT NOT NULL,
    player2 TEXT NOT NULL,
    score1 INT DEFAULT 0,
    score2 INT DEFAULT 0,
    winner TEXT,
    season_number INT NOT NULL DEFAULT 1,
    FOREIGN KEY(player1)
        REFERENCES league(player)
    FOREIGN KEY(player2)
        REFERENCES league(player)
);

CREATE TABLE main.schedule(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    round INT NOT NULL,
    start_date TEXT,
    end_date TEXT,
    season_number INT NOT NULL DEFAULT 1
    FOREIGN KEY(round)
        REFERENCES rounds(round)
);

CREATE TABLE main.audit_log(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ip_address TEXT,
    audit_date TEXT,
    action TEXT,
    path TEXT,
    content TEXT
);

CREATE TABLE main.signup(
    player TEXT NOT NULL,
    email TEXT NOT NULL,
    season_number INT NOT NULL
);
