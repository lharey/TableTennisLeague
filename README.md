## Setup:

### Config

Copy tabletennisleague.conf.example to tabletennisleague.conf and update

### Database

sqlite3 table_tennis.db

sql script is in script/sql/db.sql

## To Start Application:
```perl
plackup -Ilib tabletennisleague.psgi
```

### To set up a season

Once players have signed-up using the Signup link in the webpage run the new_season.pl script:

```perl
perl script/new_season.pl -s 1
```

## Notes

Any changes to the schema run:
perl script/tabletennisleague_create.pl model DB DBIC::Schema Schema \ create=static dbi:SQLite:table_tennis.db
